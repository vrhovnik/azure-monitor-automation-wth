<# 
# SYNOPSIS 
# TTA PowerShell script to setup initial software to be installed on VM
#
# NOTES:
# Author      : Bojan Vrhovnik
# GitHub      : https://github.com/vrhovnik
# Version 0.2.8
# SHORT CHANGE DESCRIPTION: initial script to install software
#>

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

Start-Transcript -Path "$HOME/Downloads/Logs/01-software-install.log"

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

Write-Host "Install SQL express engine"
Invoke-WebRequest "https://go.microsoft.com/fwlink/?LinkID=866658" -o "$env:temp\sqlsetup.exe"

$args = New-Object -TypeName System.Collections.Generic.List[System.String]
$args.Add("/ACTION=install")
$args.Add("/Q")
$args.Add("/IACCEPTSQLSERVERLICENSETERMS")

Write-Host "Installing SQL Express silently..."
Start-Process -FilePath "$env:temp\sqlsetup.exe" -ArgumentList $args -NoNewWindow -Wait -PassThru

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

# ASP.NET core hosting module download
# DIRECT LINK: https://download.visualstudio.microsoft.com/download/pr/c5e0609f-1db5-4741-add0-a37e8371a714/1ad9c59b8a92aeb5d09782e686264537/dotnet-hosting-6.0.8-win.exe
# GENERAL LINK https://dotnet.microsoft.com/permalink/dotnetcore-current-windows-runtime-bundle-installer
Write-Host "Getting ASP.NET Core hosting module to support .NET Core..."
Invoke-WebRequest "https://download.visualstudio.microsoft.com/download/pr/c5e0609f-1db5-4741-add0-a37e8371a714/1ad9c59b8a92aeb5d09782e686264537/dotnet-hosting-6.0.8-win.exe" -o "$env:temp\hosting.exe"

Write-Host "Installing ASP.NET Core hosting"
$args = New-Object -TypeName System.Collections.Generic.List[System.String]
$args.Add("/quiet")
$args.Add("/install")
$args.Add("/norestart")

$Output = Start-Process -FilePath "$env:temp\hosting.exe" -ArgumentList $args -NoNewWindow -Wait -PassThru
If($Output.Exitcode -Eq 0)
{
    net stop was /y
    net start w3svc
}
else {
    Write-HError "`t`t Something went wrong with the installation, ASP.NET hosting module not installed. Errorlevel: ${Output.ExitCode}"
    Exit 1
}

Stop-Transcript


