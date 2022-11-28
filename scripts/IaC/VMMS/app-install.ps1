<# 
# SYNOPSIS
# TTA PowerShell script to setup web application to be installed on VM
#
# DESCRIPTION
# installs all neccessary file to be installed on VM with getting back address to be able to access it
#
# NOTES
# Author      : Bojan Vrhovnik
# GitHub      : https://github.com/vrhovnik
# Version 0.3.1
# SHORT CHANGE DESCRIPTION: 
#>

param (
    [string]$sqlConnectionString=""    
)

if ($sqlConnectionString -eq $null) {
    Write-Host "No SQL connection string provided, reading from ENV string"
    $sqlConnectionString=$Env:AMA_SQLServerConn
    Write-Host "Conn string set to: $sqlConnectionString - we do recommend using Azure KeyVault for secure access"
    ## az keyvault secret show --name "ExamplePassword" --vault-name "<your-unique-keyvault-name>" --query "value"
}

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

Start-Transcript

Write-Host "Getting source code and storing it to $HOME/amaw"
$zipPath="https://github.com/vrhovnik/azure-monitor-automation-wth/archive/refs/heads/main.zip"
Set-Location $HOME
Invoke-WebRequest -Uri $zipPath -OutFile "$HOME\amaw.zip"
#extract to amaw folder
Expand-Archive -Path "$HOME\amaw.zip" -DestinationPath "$HOME\amaw" -Force

Write-Host "Changed location to $HOME/amaw/azure-monitor-automation-wth-main/src/TTASLN/TTA.Web"
Set-Location "$HOME/amaw/azure-monitor-automation-wth-main/src/TTASLN/TTA.Web"

$rootPath = "C:\Inetpub\wwwroot\"
Write-Host "Creating Folder Web and publishing solution Web to wwwroot"
mkdir "$rootPath\Web"
dotnet publish --configuration Release -o "$rootPath\Web"

Write-Host "DotNet publish for Web done, doing same for API"
Write-Host "Changed location to $HOME/amaw/src/TTASLN/TTA.Web.ClientAPI"
Set-Location "$HOME/amaw/azure-monitor-automation-wth-main/src/TTASLN/TTA.Web.ClientAPI"

Write-Host "Creating Folder WebClient and publishing solution Client to wwwroot"
mkdir "$rootPath\WebClient"
dotnet publish --configuration Release -o "$rootPath\WebClient"

Write-Host "Create web applications directories in IIS - ttaweb and ttawebclient"
New-WebApplication -Site "Default Web Site" -Name "ttaweb" -PhysicalPath "C:\Inetpub\wwwroot\Web" -ApplicationPool "DefaultAppPool"
New-WebApplication -Site "Default Web Site" -Name "ttawebclient" -PhysicalPath "C:\Inetpub\wwwroot\WebClient" -ApplicationPool "DefaultAppPool"

Write-Host "Fix connection string in settings file to point to correct urls"
$appSettings = Get-Content -Path "$rootPath\Web\appsettings.json" | ConvertFrom-Json
$previousClientUrl = $appSettings.AppOptions.ClientApiUrl
Write-Host "Current path to client $previousClientUrl, changing to new value https://localhost/ttawebclient"
$appSettings.AppOptions.ClientApiUrl = "https://localhost/ttawebclient/"
$sqlConn = $sqlConnectionString
Write-Host "Path changed, setting SQL connection string $sqlConn to new one for Web page"
$appSettings.SqlOptions.ConnectionString=$sqlConn

Set-Content -Path "$rootPath\Web\appsettings.json" -Value ($appSettings | ConvertTo-Json)

$appSettings = Get-Content -Path "$rootPath\WebClient\appsettings.json" | ConvertFrom-Json
Write-Host "Path changed, setting SQL connection string $sqlConn to new one for Web REST client page"
$appSettings.SqlOptions.ConnectionString=$sqlConn
Set-Content -Path "$rootPath\WebClient\appsettings.json" -Value ($appSettings | ConvertTo-Json)
Write-Host "Settings changed, restarting IIS"

net stop was /y
net start w3svc

Write-Host "Restart done, app is ready on https://localhost/ttaweb"
Write-Host "and api on https://localhost/ttawebclient"

Stop-Transcript