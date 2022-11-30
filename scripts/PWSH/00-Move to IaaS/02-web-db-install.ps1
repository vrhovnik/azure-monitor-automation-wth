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
# Version 0.2.4
# SHORT CHANGE DESCRIPTION: added transcript to be able to see installation log, if anything wrong
#>

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"
$ProgressPreference="SilentlyContinue"

Start-Transcript

Write-Host "Install SQL express engine"
Invoke-WebRequest "https://go.microsoft.com/fwlink/?LinkID=866658" -o "$PWD\sqlsetup.exe"

$args = New-Object -TypeName System.Collections.Generic.List[System.String]
$args.Add("/ACTION=install")
$args.Add("/Q")
$args.Add("/IACCEPTSQLSERVERLICENSETERMS")

Write-Host "Installing SQL Express silently..."
Start-Process -FilePath "$PWD\sqlsetup.exe" -ArgumentList $args -NoNewWindow -Wait -PassThru

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

#compile SQL generator to generate data and databases
Set-Location "$HOME/amaw/azure-monitor-automation-wth-main/src/TTASLN/TTA.DataGenerator.SQL"

#path bin\Release\net6.0\TTA.DataGenerator.SQL.ddl
# check connectivity to SQL server
$sqlConn = "Data Source=$env:COMPUTERNAME\SQLEXPRESS;Integrated Security=true;"

#prepare ENV parameters to run the database creation and assesment
New-Item -Path Env:\SQL_CONNECTION_STRING -Value "$sqlConn Initial Catalog=master;"
New-Item -Path Env:\FOLDER_ROOT -Value "$HOME/amaw/azure-monitor-automation-wth-main"
New-Item -Path Env:\DROP_DATABASE -Value "true"
New-Item -Path Env:\CREATE_TABLES -Value "true"
New-Item -Path Env:\DEFAULT_PASSWORD -Value "Password123!"
New-Item -Path Env:\RECORD_NUMBER -Value "200"

dotnet run 

Write-Host "Data insert done. Fix connection string in settings file to point to correct urls"
$appSettings = Get-Content -Path "$rootPath\Web\appsettings.json" | ConvertFrom-Json
$previousClientUrl = $appSettings.AppOptions.ClientApiUrl
Write-Host "Current path to client $previousClientUrl, changing to new value https://localhost/ttawebclient"
$appSettings.AppOptions.ClientApiUrl = "https://localhost/ttawebclient/"
$sqlConn = $sqlConn + "Initial Catalog=TTADB";
Write-Host "Path changed, setting SQL connection string $sqlConn to new one for Web page"
$appSettings.SqlOptions.ConnectionString=$sqlConn
Set-Content -Path "$rootPath\Web\appsettings.json" -Value ($appSettings | ConvertTo-Json)

$appSettings = Get-Content -Path "$rootPath\WebClient\appsettings.json" | ConvertFrom-Json
Write-Host "Changing settings for clientapp, setting SQL connection string $sqlConn to new one for Web REST client page"
$appSettings.SqlOptions.ConnectionString=$sqlConn
Set-Content -Path "$rootPath\WebClient\appsettings.json" -Value ($appSettings | ConvertTo-Json)
Write-Host "Settings changed, adding .NET core hosting to IIS"

# ASP.NET core hosting module download
# DIRECT LINK: https://download.visualstudio.microsoft.com/download/pr/c5e0609f-1db5-4741-add0-a37e8371a714/1ad9c59b8a92aeb5d09782e686264537/dotnet-hosting-6.0.8-win.exe
# GENERAL LINK https://dotnet.microsoft.com/permalink/dotnetcore-current-windows-runtime-bundle-installer
Write-Host "Getting ASP.NET Core hosting module to support .NET Core..."
Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/8de163f5-5d91-4dc3-9d01-e0b031a03dd9/0170b328d569a49f6f6a080064309161/dotnet-hosting-7.0.0-win.exe" -OutFile "$PWD\hosting.exe"

Write-Host "Installing ASP.NET Core hosting"
$args = New-Object -TypeName System.Collections.Generic.List[System.String]
$args.Add("/quiet")
$args.Add("/install")
$args.Add("/norestart")

Start-Process -FilePath "$PWD\hosting.exe" -ArgumentList $args -NoNewWindow -Wait -PassThru

net stop was /y
net start w3svc

Write-Host "Restart done, app is ready on https://localhost/ttaweb and api on https://localhost/ttawebclient"

#stop scheduled task for it no to be running every time user logs in
Stop-ScheduledTask -TaskName "MyLogonToMachine"

Stop-Transcript