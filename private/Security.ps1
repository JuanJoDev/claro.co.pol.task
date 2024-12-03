function GetEncryptedKeyFromFile {
    param(
        [string]$File
    )
    try {
        if (-not (Test-Path -Path $File)) {
            WriteLog -Level "EXCEPTION" -Tittle "Exception: GetEncryptedKeyFromFile" -Message "Encrypted password file not found: $EncryptedPasswordFile"
            
        }
        $SecurePassword = Get-Content -Path $File | ConvertTo-SecureString
        $PlainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword))
    }
    catch {
        WriteLog -Level "EXCEPTION" -Tittle "Exception: GetEncryptedKeyFromFile" -Message $_
        exit 1
    }

    return $PlainPassword
}