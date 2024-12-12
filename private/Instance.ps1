function IsInstanceRunning {
    param(
        [string]$LockFile
    )    
    try {    
        if (Test-Path $LockFile) {
            WriteLog -Level "WARNING" -Tittle "IsInstanceRunning" -Message "Another instance is running. Exiting..."   
            exit
        }
        New-Item -ItemType File -Path $LockFile | Out-Null        
    }
    catch {
        WriteLog -Level "EXCEPTION" -Tittle "Exception: IsInstanceRunning" -Message $_
    }    
}

function RemoveLock {
    param(
        [string]$LockFile
    )    
    try {    
        if (Test-Path $LockFile) {
            Remove-Item -Path $LockFile
            WriteLog -Level "INFORMATION" -Tittle "RemoveLock" -Message "Se eliminó el archivo temporal: $LockFile"
        }         
    }
    catch {
        WriteLog -Level "EXCEPTION" -Tittle "Exception: RemoveLock" -Message $_
    }    
}