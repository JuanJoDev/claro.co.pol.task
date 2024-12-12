function LoadConfigFileToCache {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ConfigFilePath
    )

    $script:ConfigCache = $null

    try {

        if (-not (Test-Path -Path $ConfigFilePath)) {
            throw "El archivo de configuración no existe: $ConfigFilePath"
        }

        $xmlConfig = [xml](Get-Content -Path $ConfigFilePath -ErrorAction Stop)

        $script:ConfigCache = [PSCustomObject]@{
            DirectoryTree    = @{
                Root    = $xmlConfig.config.DirectoryTree.root.add.'value'
                Folders = @{}
            }
            MasksFormat      = @{
                DateFormat     = $xmlConfig.config.MasksFormat.add | Where-Object { $_.key -eq "dateFormat" } | Select-Object -ExpandProperty value
                DateTimeFormat = $xmlConfig.config.MasksFormat.add | Where-Object { $_.key -eq "dateTimeFormat" } | Select-Object -ExpandProperty value
            }
            SourceFile       = @{
                SecurityKeyPath  = $xmlConfig.config.SourceFile.add | Where-Object { $_.key -eq "SecurityKeyPath" } | Select-Object -ExpandProperty value
                QryUpdUserSuport = $xmlConfig.config.SourceFile.add | Where-Object { $_.key -eq "QryUpdUserSuport" } | Select-Object -ExpandProperty value
                QrySlcUserSuport = $xmlConfig.config.SourceFile.add | Where-Object { $_.key -eq "QrySlcUserSuport" } | Select-Object -ExpandProperty value
                LockFile         = $xmlConfig.config.SourceFile.add | Where-Object { $_.key -eq "LockFile" } | Select-Object -ExpandProperty value
            }
            ConnectionString = @{
                ConnectionString = $xmlConfig.config.ConnectionString.add.'value' 
            }
            Package          = @{
                ODP = @{}
            }
            Validators       = @{
                checkDirectoryStructure = ($xmlConfig.config.Validator.add | Where-Object { $_.key -eq "checkDirectoryStructure" } | Select-Object -ExpandProperty value) -as [bool]
            }
            Database         = @{
                User       = $xmlConfig.config.Database.add | Where-Object { $_.key -eq "User" } | Select-Object -ExpandProperty value
                DataSource = $xmlConfig.config.Database.add | Where-Object { $_.key -eq "DataSource" } | Select-Object -ExpandProperty value
            }
        }

        foreach ($folder in $xmlConfig.config.DirectoryTree.folder.add) {
            $script:ConfigCache.DirectoryTree.Folders[$folder.key] = $folder.value
        }

        foreach ($provider in $xmlConfig.config.Package.add) {
            $script:ConfigCache.Package[$provider.key] = $provider.value
        }
        
        WriteLog -Level "INFORMATION" -Tittle "LoadConfigFileToCache" -Message "Archivo de configuración cargado en memoria."
    }
    catch {
        WriteLog -Level "EXCEPTION" -Tittle "LoadConfigFileToCache" -Message "$_"
    }
}

function GetConfigCache {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Key
    )

    if (-not $script:ConfigCache) {
        throw "La configuración no está cargada en la memoria. Use Load-ConfigFileToCache primero."
    }

    if ($script:ConfigCache.PSObject.Properties[$Key]) {
        return $script:ConfigCache.$Key
    }
    else {
        throw "La clave '$Key' no se encuentra en la configuración."
    }
}

