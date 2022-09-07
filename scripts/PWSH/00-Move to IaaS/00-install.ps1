<# 
# SYNOPSIS
# Installs script
#
# DESCRIPTION
# installs all neccessary file to be installed on VM with getting back address to be able to access it
#
# NOTES
# Author      : Bojan Vrhovnik
# GitHub      : https://github.com/vrhovnik
# Version 0.1.4
# SHORT CHANGE DESCRIPTION: fixed start process argument list  
#>

Start-Transcript -Path "$HOME/Downloads/Logs/bootstrapper.log"
$scriptPath = "$HOME/Downloads/"

Write-Host "Extending C:\ partition to the maximum size"
Resize-Partition -DriveLetter C -Size $(Get-PartitionSupportedSize -DriveLetter C).SizeMax

# Download script
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Write-Host "Download software installation script"
Invoke-WebRequest "https://go.azuredemos.net/ama-01-software-install" -o "$scriptPath/01-software-install-and-configuration.ps1"

Write-Host "Download web deployment and software installation script"
Invoke-WebRequest "https://go.azuredemos.net/ama-02-app-and-db-configuration" -o "$scriptPath/02-web-db-install.ps1"

$scriptPath = "$HOME/Downloads/01-software-install-and-configuration.ps1"
Write-Host "Calling first script at $scriptPath"
$args = New-Object -TypeName System.Collections.Generic.List[System.String]
$args.Add("-ExecutionPolicy Unrestricted")

Start-Process powershell.exe -ArgumentList $args -FilePath $scriptPath -NoNewWindow -Wait

$scriptPath = "$HOME/Downloads/02-web-db-install.ps1"
Start-Process powershell.exe -ArgumentList $args -FilePath $scriptPath -NoNewWindow -Wait

Stop-Transcript