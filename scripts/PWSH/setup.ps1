# 
.SYNOPSIS
TTA PowerShell script to setup initial software to be installed on VM

.DESCRIPTION
installs all neccessary tools to be able to run applicaton on VM

.NOTES
Author      : Bojan Vrhovnik
GitHub      : https://github.com/vrhovnik
Version 0.0.1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

# you will be installing tools we need admin access 
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) 
{
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

Write-Host "Creating Restore Point in case something bad happens to restore back to original state"
Enable-ComputerRestore -Drive "C:\"
Checkpoint-Computer -Description "RestoreBeforeTTA" -RestorePointType "MODIFY_SETTINGS"

Write-Host "Enabling and starting Diagnostics Tracking Service..."
Set-Service "DiagTrack" -StartupType Automatic
Start-Service "DiagTrack"

Write-Host "Hiding Search Box / Button to spare space..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWord -Value 0

Write-Host "Showing known file extensions..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Type DWord -Value 0

# Network Tweaks
Write-Host "Optimizing networking for faster download..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "IRPStackSize" -Type DWord -Value 20

# Group svchost.exe processes
Write-Host "Grouping svchost.exe processes to be able to see in task manager easily..."
$ram = (Get-CimInstance -ClassName Win32_PhysicalMemory | Measure-Object -Property Capacity -Sum).Sum / 1kb
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control" -Name "SvcHostSplitThresholdInKB" -Type DWord -Value $ram -Force

# installing wget to 
Write-Host "Checking winget..."

# Check if winget is installed
if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe)
{
    'Winget already installed'
}
else
{
    # Installing winget from the Microsoft Store
    Write-Host "Winget not found, installing it now from Windows Store."
    Start-Process "ms-appinstaller:?source=https://aka.ms/getwinget"
    $nid = (Get-Process AppInstaller).Id
    Wait-Process -Id $nid
    Write-Host "Winget Installed"    
}

Write-Host "Installing  Windows Terminal ...  please wait ..."
winget install -e Microsoft.WindowsTerminal | Out-Host
if($?) { Write-Host "Installed New Windows Terminal" }

Write-Host "Installing Git ... please wait ...."
winget install -e Git.Git | Out-Host

# installing dotnet core 6
Write-Host "Installing .NET Core 6 - installing SDK which will install .NET Core 6 runtime as well"
winget install Microsoft.DotNet.SDK.6

## enable IIS
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


