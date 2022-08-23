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
# Version 0.2.3
#>

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

Start-Transcript -Path "$HOME/Downloads/Logs/02-app-and-db-condiguration.log"

# you will be installing web app inside IIS 
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
{
    $scriptPath = "$HOME/Downloads/02-web-db-install.ps1"
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    Exit    
}

Write-Host "Getting source code and storing it to $HOME/amaw"
git clone https://github.com/vrhovnik/azure-monitor-automation-wth.git "$HOME/amaw"

Write-Host "Changed location to $HOME/amaw/src/TTASLN/TTA.Web"
Set-Location "$HOME/amaw/src/TTASLN/TTA.Web"

$rootPath = "C:\Inetpub\wwwroot\"
Write-Host "Creating Folder Web and publishing solution Web to wwwroot"
mkdir "$rootPath\Web"
dotnet publish --configuration Release -o "$rootPath\Web"

Write-Host "DotNet publish for Web done, doing same for API"
Write-Host "Changed location to $HOME/amaw/src/TTASLN/TTA.Web.ClientAPI"
Set-Location "$HOME/amaw/src/TTASLN/TTA.Web.ClientAPI"

Write-Host "Creating Folder WebClient and publishing solution Client to wwwroot"
mkdir "$rootPath\WebClient"
dotnet publish --configuration Release -o "$rootPath\WebClient"

Write-Host "Create virtual directories in IIS - ttaweb and ttawebclient"
New-WebVirtualDirectory -Site "Default Web Site" -Name "ttaweb" -PhysicalPath "C:\Inetpub\wwwroot\Web"
New-WebVirtualDirectory -Site "Default Web Site" -Name "ttawebclient" -PhysicalPath "C:\Inetpub\wwwroot\WebClient"

#compile SQL generator to generate data and databases
Set-Location "$HOME/amaw/src/TTASLN/TTA.DataGenerator.SQL"

#path bin\Release\net6.0\TTA.DataGenerator.SQL.ddl
# check connectivity to SQL server
$sqlConn = "Data Source=$env:COMPUTERNAME\SQLEXPRESS;Integrated Security=true;"

#prepare ENV parameters to run the database creation and assesment
New-Item -Path Env:\SQL_CONNECTION_STRING -Value "$sqlConn;Initial Catalog=master;"
New-Item -Path Env:\FOLDER_ROOT -Value "$HOME/amaw"
New-Item -Path Env:\DROP_DATABASE -Value "true"
New-Item -Path Env:\CREATE_TABLES -Value "true"
New-Item -Path Env:\DEFAULT_PASSWORD -Value "Password123!"
New-Item -Path Env:\RECORD_NUMBER -Value "200"

dotnet run --property:Configuration=Release

Write-Host "Fix connection string in settings file to point to correct urls"
$appSettings = Get-Content -Path "$rootPath\Web\appsettings.json" | ConvertFrom-Json
$previousClientUrl = $appSettings.AppOptions.ClientApiUrl
Write-Host "Current path to client $previousClientUrl, changing to new value https://localhost/ttawebclient"
$appSettings.AppOptions.ClientApiUrl = "https://localhost/ttawebclient/"
$sqlConn = $appSettings.SqlOptions.ConnectionString
Write-Host "Path changed, setting SQL connection string $sqlConn to new one for Web page"
$appSettings.SqlOptions.ConnectionString=$sqlConn

Set-Content -Path "$rootPath\Web\appsettings.json" -Value ($appSettings | ConvertTo-Json)

$appSettings = Get-Content -Path "$rootPath\WebClient\appsettings.json" | ConvertFrom-Json
$sqlConn = $appSettings.SqlOptions.ConnectionString
Write-Host "Path changed, setting SQL connection string $sqlConn to new one for Web REST client page"
$appSettings.SqlOptions.ConnectionString=$sqlConn
Set-Content -Path "$rootPath\WebClient\appsettings.json" -Value ($appSettings | ConvertTo-Json)
Write-Host "Settings changed, restarting IIS"

net stop was /y
net start w3svc

Write-Host "Restart done, app is ready on https://localhost/ttaweb"
