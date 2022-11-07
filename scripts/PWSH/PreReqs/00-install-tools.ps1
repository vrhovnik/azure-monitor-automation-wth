Write-Host "Installing chocolatey"

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Write-Host "Installing  dotnet SDK ... "
choco install -y dotnet-sdk

Write-Host "Installing Git ... "
choco install -y git

Write-Host "Installing GitHub ... "
choco install -y gh

Write-Host "Installing Azure CLI"
choco install -y azure-cli

Write-Host "Installing PowerShell AZ module"
choco install -y az.powershell -Force

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

dotnet run

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