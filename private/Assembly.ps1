function LoadAssembly {
    param (
        [string]$LoadAssembly
    )

    try {
        Add-Type -Path $LoadAssembly -ErrorAction Stop
        WriteLog -Level "INFORMATION" -Tittle "LoadAssembly" -Message "El ensamblado se cargó correctamente desde: $LoadAssembly"
        return $true
    }
    catch {
        WriteLog -Level "EXCEPTION" -Tittle "LoadAssembly" -Message "Error: No se pudo cargar el ensamblado desde la ruta: $LoadAssembly, $_"
        return $false
    }
}

function GetAssembly {
    param (
        [string]$AssemblyName
    )

    $assemblies = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.FullName -like "*$AssemblyName*" }

    if ($assemblies) {
        $assemblies | ForEach-Object {
            [PSCustomObject]@{
                Nombre    = $_.FullName
                Versión   = $_.ImageRuntimeVersion
                Ubicación = $_.Location
            }
        }
    }
    else {
        WriteLog -Level "WARNING" -Tittle "LoadAssembly" -Message "El ensamblado '$AssemblyName' no está cargado en el dominio actual."        
    }
}

