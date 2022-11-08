<# 
# SYNOPSIS 
# TTA PowerShell script to setup initial software to be installed on VM
#
# NOTES:
# Author      : Bojan Vrhovnik
# GitHub      : https://github.com/vrhovnik
# Version 0.2.8
# SHORT CHANGE DESCRIPTION: add script at logon
#>
param (
    [string]$adminUsername,
    [string]$scriptPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

## Turn on transcripting
$registryPath = @{
    Path = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription'
    Force = $True
}
New-Item @registryPath

$dwordOne = @{
    PropertyType = 'DWord'
    Value = 1
}
New-ItemProperty @registryPath -Name 'EnableTranscripting' @dwordOne
New-ItemProperty @registryPath -Name 'EnableInvocationHeader' @dwordOne
New-ItemProperty @registryPath -Name 'OutputDirectory' -PropertyType 'String' -Value 'C:\Temp'

Start-Transcript 

Write-Host "Enabling and starting Diagnostics Tracking Service..."
Set-Service "DiagTrack" -StartupType Automatic
Start-Service "DiagTrack"

#Write-Host "Hiding Search Box / Button to spare space..."
#Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0

#Write-Host "Showing known file extensions..."
#Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0

# Network Tweaks
#Write-Host "Optimizing networking for faster download..."
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "IRPStackSize" -Type DWord -Value 20

# Group svchost.exe processes
#Write-Host "Grouping svchost.exe processes to be able to see in task manager easily..."
#$ram = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1kb
#Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $ram -Force

# installing chocolatey to install additional services 
Write-Host "Installing chocolatey"

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Write-Host "Installing  dotnet SDK ... "
choco install -y dotnet-sdk

Write-Host "Installing Git ... "
choco install -y git

Write-Host "Installing Azure CLI"
choco install -y azure-cli

Write-Host "Installing PowerShell AZ module"
choco install -y az.powershell -Force

Write-Host "Installing Sysinternals ZoomIt"
choco install -y zoomit

# enable IIS
Write-Host "Continue with enabling IIS on the machine"
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
Enable-WindowsOptionalFeature -online -FeatureName NetFx4Extended-ASPNET45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-LoggingLibraries
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestMonitor
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpTracing
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-BasicAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WindowsAuthentication
Enable-WindowsOptionalFeature -Online -FeatureName IIS-StaticContent
Enable-WindowsOptionalFeature -Online -FeatureName IIS-DefaultDocument
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebSockets
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationInit
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIExtensions
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ISAPIFilter
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpCompressionStatic
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45

$Env:ItemsDir="C:\TempInstall"
New-Item -Path $Env:ItemsDir -ItemType directory -Force
Invoke-WebRequest $scriptPath -o $Env:ItemsDir\02-web-db-install.ps1

& $Env:ItemsDir\02-web-db-install.ps1

#set execution at logon
#$Trigger = New-ScheduledTaskTrigger -AtLogOn
#$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument $Env:ItemsDir\02-web-db-install.ps1
#Register-ScheduledTask -TaskName "MyLogonToMachine" -Trigger $Trigger -User $adminUsername -Action $Action -RunLevel "Highest" -Force

Stop-Transcript

# call web install
#.\02-web-db-install.ps1

