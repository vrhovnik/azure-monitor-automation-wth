$ProgressPreference = 'SilentlyContinue';
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi;
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet';
# cleanup of Azure CLI
Remove-Item .\AzureCLI.msi

# test out if your solution is working
az login
#check the subscription
az account list --output table

#set the installation of extensions without prompt
az config set extension.use_dynamic_install=yes_without_prompt
az extension add --name containerapp --upgrade
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.OperationalInsights

# install bicep
$installPath = "$env:USERPROFILE\.bicep"
$installDir = New-Item -ItemType Directory -Path $installPath -Force
$installDir.Attributes += 'Hidden'
# Fetch the latest Bicep CLI binary
(New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")
# Add bicep to your PATH
$currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
# Verify you can now access the 'bicep' command.
bicep --help
# upgrade to latest version
az bicep upgrade

# download zip and navigate to the folder
Write-Host "Getting source code and storing it to $HOME/amaw"
$zipPath="https://github.com/vrhovnik/azure-monitor-automation-wth/archive/refs/heads/main.zip"
Set-Location $HOME
Invoke-WebRequest -Uri $zipPath -OutFile "$HOME\amaw.zip"
#extract to amaw folder
Expand-Archive -Path "$HOME\amaw.zip" -DestinationPath "$HOME\amaw" -Force

Write-Host "Changed location to $HOME/amaw/azure-monitor-automation-wth-main/"
Set-Location "$HOME/amaw/azure-monitor-automation-wth-main/scripts/IaC"

Write-Host "Download completed, you can now continue with the next step"