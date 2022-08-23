# login to Azure account
az login

# upgrade bicep to latest version
# if you don't have it installed 
# Chocolatey
# choco install bicep
# Winget
#  winget install -e --id Microsoft.Bicep
# Powershell
# Create the install folder
#$installPath = "$env:USERPROFILE\.bicep"
#$installDir = New-Item -ItemType Directory -Path $installPath -Force
#$installDir.Attributes += 'Hidden'
# Fetch the latest Bicep CLI binary
#(New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")
# Add bicep to your PATH
#$currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
#if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
#if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
# Verify you can now access the 'bicep' command.
#bicep --help

# upgrade to latest version
az bicep upgrade

# check account 
az account list --output table 

# create new resource group (you can name it whatever you want)
az group create -l WestEurope -n TTARG

# use what-if to check what will happen to resource group
# https://docs.microsoft.com/en-us/cli/azure/deployment/group?view=azure-cli-latest#az-deployment-group-what-if
az deployment group what-if --resource-group TTARG --template-file bootstrap.bicep --parameters bootstrap.parameters.json

# deploy to azure group 
az deployment group create --resource-group TTARG --template-file bootstrap.bicep --parameters bootstrap.parameters.json 

# copy IP from the console to connect via RDP
Start-Process "$env:windir\system32\mstsc.exe"
