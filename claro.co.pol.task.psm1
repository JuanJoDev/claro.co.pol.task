# claro.co.pol.task

Set-StrictMode -Version Latest

$PSModule = $ExecutionContext.SessionState.Module
$PSModuleRoot = $PSModule.ModuleBase

. (Join-Path -Path $PSModuleRoot -ChildPath "private\Messages.ps1")
. (Join-Path -Path $PSModuleRoot -ChildPath "private\Configuration.ps1")
. (Join-Path -Path $PSModuleRoot -ChildPath "private\Security.ps1")
. (Join-Path -Path $PSModuleRoot -ChildPath "private\Assembly.ps1")
. (Join-Path -Path $PSModuleRoot -ChildPath "private\Instance.ps1")
. (Join-Path -Path $PSModuleRoot -ChildPath "public\Task.ps1")



Export-ModuleMember -Function 'Invoke-MethodTask'
Export-ModuleMember -Function 'Get-LoadAssemblies'