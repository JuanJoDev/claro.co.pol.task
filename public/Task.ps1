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

function Invoke-TaskSqlPlus {
    LoadConfigFileToCache -ConfigFilePath  (Join-Path -Path $PSModuleRoot -ChildPath "claro.co.pol.task.config")
    $workspace = (GetConfigCache -Key "DirectoryTree")
    $LockFile = (Join-Path -Path $workspace.Root -ChildPath (GetConfigCache -Key "SourceFile").LockFile)
    IsInstanceRunning -LockFile $LockFile
    $EncryptedPasswordFile = (Join-Path -Path $workspace.Root -ChildPath (GetConfigCache -Key "SourceFile").SecurityKeyPath)
    $keyPlain = GetEncryptedKeyFromFile -File $EncryptedPasswordFile
    $user = (GetConfigCache -Key "Database").User
    $Datasource = (GetConfigCache -Key "Database").Datasource
    $SqlQuery = (Join-Path -Path $workspace.Root -ChildPath (GetConfigCache -Key "SourceFile").QryUpdUserSuport)

    if (-Not (Test-Path -Path $SqlQuery)) {        
        WriteLog -Level "WARNING" -Tittle "Invoke-TaskSqlPlus" -Message "El archivo SQL no existe en la ruta especificada: $SqlQuery"    
        exit 1
    }

    $Command = ("sqlplus {0}/{1}@{2} @{3}" -f $user, $keyPlain, $Datasource, $SqlQuery)

    WriteLog -Level "INFORMATION" -Tittle "Invoke-TaskSqlPlus" -Message "Command $Command "


    $tempOutputFile = [System.IO.Path]::GetTempFileName()

    try {

        Start-Process -FilePath "cmd.exe" -ArgumentList "/c $command > `"$tempOutputFile`"" -Wait -NoNewWindow
        
        $output = Get-Content -Path $tempOutputFile -Raw

        if ($output -match "(?i)(\d+)\s+fila(s)?\s+actualizada" -or $output -match "(?i)(\d+)\s+row(s)?\s+updated") {
            $rowsAffected = $matches[1]
            WriteLog -Level "INFORMATION" -Tittle "Invoke-TaskSqlPlus" -Message "Cantidad de filas afectadas: $rowsAffected"
        }
        else {
            WriteLog -Level "WARNING" -Tittle "Invoke-TaskSqlPlus" -Message "No se pudo determinar la cantidad de filas afectadas. Verifique la salida."            
        }
    }
    catch {
        WriteLog -Level "EXCEPTION" -Tittle "Invoke-TaskSqlPlus" -Message "Ocurrió un error al ejecutar el comando sqlplus: $_"          
    }
    finally {        
        if (Test-Path -Path $tempOutputFile) {
            Remove-Item -Path $tempOutputFile -Force
            WriteLog -Level "INFORMATION" -Tittle "Invoke-TaskSqlPlus" -Message "Se eliminó el archivo temporal: $tempOutputFile"        
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