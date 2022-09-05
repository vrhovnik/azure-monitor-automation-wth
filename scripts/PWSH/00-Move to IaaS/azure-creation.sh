# login to Azure account
az login
# check account 
az account list --output table
# Set account, if you have multiple libraries
#az account set -s NAME_OR_ID

##########################################
### Move To Infrastructure as Service  ###
##########################################

rgName='TTARG'
# az account list-locations
# to define location  
regionToDeploy="WestEurope"
vmName="tta-vm-2022"

# set default resource group
az config set defaults.group=$rgName

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

# create new resource group (you can name it whatever you want)
# if you want to confirm it before - az group create -l $regionToDeploy -n $rgName --confirm-with-what-if -c
az group create -l $regionToDeploy -n $rgName 

# use what-if to check what will happen to resource group
# https://docs.microsoft.com/en-us/cli/azure/deployment/group?view=azure-cli-latest#az-deployment-group-what-if
az deployment group what-if --resource-group $rgName --template-file vm.bicep --parameters vm.parameters.json

# deploy to azure group 
vmSettings=az deployment group create --resource-group $rgName --template-file vm.bicep --parameters vm.parameters.json 

#get the IP back
myIp=vmSettings.publicIP

# show IP and FQDN with query and use them
# vmSettings=az network public-ip show -g $rgName -n "$vmName-PIP" --query "{fqdn: dnsSettings.fqdn, address: ipAddress}"
# myIp=vmSettings.fqdn

# copy IP from the deployment output to connect via RDP into the newly created VM
Start-Process "$env:windir\system32\mstsc.exe" -ArgumentList "/v:$myIp:3389 /f" 