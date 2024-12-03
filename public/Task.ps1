using namespace System.Data
function Invoke-MethodTask {
    LoadConfigFileToCache -ConfigFilePath  (Join-Path -Path $PSModuleRoot -ChildPath "claro.co.pol.task.config")
    $workspace = (GetConfigCache -Key "DirectoryTree")
    $LockFile = (Join-Path -Path $workspace.Root -ChildPath (GetConfigCache -Key "SourceFile").LockFile)
    IsInstanceRunning -LockFile $LockFile
    $EncryptedPasswordFile = (Join-Path -Path $workspace.Root -ChildPath (GetConfigCache -Key "SourceFile").SecurityKeyPath)
    $connectionString = (GetConfigCache -Key "ConnectionString").ConnectionString
    $keyPlain = GetEncryptedKeyFromFile -File $EncryptedPasswordFile
    $OracleConnectionString = ($connectionString -f $keyPlain)
    $SqlQuery = Get-Content -Path (Join-Path -Path $workspace.Root -ChildPath (GetConfigCache -Key "SourceFile").QryUpdUserSuport)
    $OracleConnection = $null
    
    try {

        LoadAssembly -LoadAssembly (Join-Path -Path $PSModuleRoot -ChildPath (Join-Path "shared" (GetConfigCache -Key "Package").ODP))        

        $OracleConnection = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($OracleConnectionString)
        $OracleConnection.Open()

        $Command = $OracleConnection.CreateCommand()
        $Command.CommandText = $SqlQuery

        $Result = $Command.ExecuteNonQuery()

        if ($Result -gt 0) {

            WriteLog -Level "INFORMATION" -Tittle "Test-MethodTask" -Message "SQL script executed successfully. Result: $Result"
        }      
    }
    catch {
        WriteLog -Level "EXCEPTION" -Tittle "Test-MethodTask" -Message "$_"
    }
    finally {
        if ($OracleConnection -and $OracleConnection.State -eq [System.Data.ConnectionState]::Open) {
            $OracleConnection.Close()
            WriteLog -Level "INFORMATION" -Tittle "Test-MethodTask" -Message "Oracle connection closed."            
        }
        RemoveLock -LockFile $LockFile
    }
}

function Get-LoadAssemblies {
    param (
        [string]$AssemblyName
    )
    GetAssembly -AssemblyName $AssemblyName
}