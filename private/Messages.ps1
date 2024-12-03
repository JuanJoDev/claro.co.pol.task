function SendException {
    param ($Message, $Exception)
    Write-Output "Error: $Message"
    Write-Output "Detalles: $($ .Exception.Message)"
}

function WriteLog {
    param ( [string]$Level = "INFO", [string]$Tittle, [string]$Message  )

    try {
        $LogFile = Join-Path -Path (GetConfigCache -Key "DirectoryTree").Root -ChildPath (("log\log_{0}.log" -f (Get-Date -Format "yyyyMMdd")))

        if (-not (Test-Path -Path $LogFile)) {
            New-Item -ItemType File -Path $LogFile | Out-Null
        }

        $LogMessage = ("{0} [{1}] {2} {3}" -f $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Tittle, $Message)
    
        Add-Content -Path $LogFile -Value $LogMessage

        $foregroundColor = switch ($Level) {
            "INFORMATION" { "White" }
            "WARNING" { "Yellow" }
            "EXCEPTION" { "Red" }
            Default { "Red" }
        }

        Write-Host ("{0} `n [{1}] `n {2} `n {3}" -f $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Tittle, $Message) -ForegroundColor $foregroundColor      
    }
    catch {
        Write-Host -Message "[WriteLog] $_"
    }
}

function ConfirmAction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [string[]]$ValidResponses = @('Y', 'N'),
        [string]$DefaultResponse = 'N'
    )

    if (-not ($ValidResponses -contains $DefaultResponse)) {
        throw "La respuesta predeterminada '$DefaultResponse' no está en la lista de respuestas válidas: $ValidResponses"
    }

    while ($true) {
        $response = Read-Host "$Message [$($ValidResponses -join '/')], por defecto: '$DefaultResponse'"

        if (-not $response) {
            $response = $DefaultResponse
        }

        if ($ValidResponses -contains $response.ToUpper()) {
            return $response.ToUpper() -eq 'Y'
        }
        else {
            Write-Host "Entrada no válida. Por favor ingrese una de las siguientes opciones: $($ValidResponses -join ', ')" -ForegroundColor Yellow
        }
    }
}