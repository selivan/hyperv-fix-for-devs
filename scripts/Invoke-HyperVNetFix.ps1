<#
.SYNOPSIS
    Enables the Hyper-V Fix, invokes a WSL2 command, then disables the adapter.
#>
param (
    # Name of the dummy adapter used for fixing the Hyper-V network.
    [string]$AdapterName = "Hyper-V Fix"
)

$logRoot = Split-Path $script:MyInvocation.MyCommand.Path -Parent
$logfilepath = Join-Path -Path $logRoot -ChildPath HyperVNetFix.log

function WriteToLogFile ($message) {
   Add-content $logfilepath -value $message
}
if (Test-Path $logfilepath) {
    Remove-Item $logfilepath
}

Get-NetAdapter -Name $AdapterName | Enable-NetAdapter
WriteToLogFile "Hyper-V Fix Adapter Enabled."

# Assuming the above steps completed successfully, let's try to start up WSL
if ( Get-NetIPAddress -IPAddress "172.16.0.1" -ErrorAction SilentlyContinue ) {
    # Run some useless command in the WSL VM to force the VM and default distro to start:
    wsl.exe --exec pwd
    WriteToLogFile "WSL Started."
}

Get-NetAdapter -Name $AdapterName | Disable-NetAdapter -Confirm:$false
WriteToLogFile "Hyper-V Fix Adapter Disabled."

WriteToLogFile "IP Config after Applying Fix:"
ipconfig | Out-File -Append -FilePath $logfilepath
