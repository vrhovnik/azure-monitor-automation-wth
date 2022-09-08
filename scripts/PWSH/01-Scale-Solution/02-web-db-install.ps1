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

# ASP.NET core hosting module download
# DIRECT LINK: https://download.visualstudio.microsoft.com/download/pr/c5e0609f-1db5-4741-add0-a37e8371a714/1ad9c59b8a92aeb5d09782e686264537/dotnet-hosting-6.0.8-win.exe
# GENERAL LINK https://dotnet.microsoft.com/permalink/dotnetcore-current-windows-runtime-bundle-installer
Write-Host "Getting ASP.NET Core hosting module to support .NET Core..."
Invoke-WebRequest "https://download.visualstudio.microsoft.com/download/pr/c5e0609f-1db5-4741-add0-a37e8371a714/1ad9c59b8a92aeb5d09782e686264537/dotnet-hosting-6.0.8-win.exe" -o "$PWD\hosting.exe"

Write-Host "Installing ASP.NET Core hosting"
$args = New-Object -TypeName System.Collections.Generic.List[System.String]
$args.Add("/quiet")
$args.Add("/install")
$args.Add("/norestart")

$Output = Start-Process -FilePath "$PWD\hosting.exe" -ArgumentList $args -NoNewWindow -Wait -PassThru
If($Output.Exitcode -Eq 0)
{
    Write-Host "ASP.NET hosting was installed, restarting IIS"
    net stop was /y
    net start w3svc
}
else {
    Write-HError "`t`t Something went wrong with the installation, ASP.NET hosting module not installed. Errorlevel: ${Output.ExitCode}"
    Exit 1
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

Write-Host "Create web applications directories in IIS - ttaweb and ttawebclient"
New-WebApplication -Site "Default Web Site" -Name "ttaweb" -PhysicalPath "C:\Inetpub\wwwroot\Web" -ApplicationPool "DefaultAppPool"
New-WebApplication -Site "Default Web Site" -Name "ttawebclient" -PhysicalPath "C:\Inetpub\wwwroot\WebClient" -ApplicationPool "DefaultAppPool"

#compile SQL generator to generate data and databases
Write-Header "Az CLI Login"
az login --service-principal --username $Env:spnClientID --password $Env:spnClientSecret --tenant $Env:spnTenantId

Write-Host "Doing an import of bacpac file"
# key is valid for 1 day - need to refresh it or call 
az sql db import -s $server -n $dbName --storage-key-type SharedAccessKey --storage-uri "https://webeudatastorage.blob.core.windows.net/ama/TTADB.bacpac" -g $rgName -p $password -u $username --storage-key "?sv=2021-04-10&st=2022-09-07T17%3A48%3A00Z&se=2022-09-09T17%3A48%3A47Z&sr=b&sp=r&sig=do3agVkOd8uQp4IJAj9HJNgGZg0HM8ZJX9%2B%2FMulqR2k%3D"

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
Write-Host "and api on https://localhost/ttawebclient"

Stop-Transcript