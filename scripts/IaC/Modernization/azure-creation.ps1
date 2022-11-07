<# 
# SYNOPSIS
# Installs and compile containers, add them to the mix and prepare the container apps
#
# DESCRIPTION
# prepared all neccessary services to host the container images and prepare the SQL to be used in the container apps environment
#
# NOTES
# Author      : Bojan Vrhovnik
# GitHub      : https://github.com/vrhovnik
# Version 0.4.6
# SHORT CHANGE DESCRIPTION: adding import SQL option
#>
param(
    [string]$regionToDeploy = "WestEurope",
    [string]$rgName = "rg-customer-ama-containers",   
    [string]$containerappenv = "my-tta-environment",   
    [string]$containerAppName = "tta-container-web"   
)
Write-Host "Starting registry deploy in $rgName in region $regionToDeploy"
# deploy to azure group 
$data = az deployment group create --resource-group $rgName --template-file registry.bicep --parameters registry.parameters.json | ConvertFrom-Json
$loginName = $data.properties.outputs.loginName.value
Write-Host "Registry created, login aquired $loginName"

# get sources - we can get it online if needed (download to local machine) - in devops pipeline you will prepare a step do download source code - for testing purposes you'll "simulate" the environet
Set-Location "../../../../"

Write-Host "Building images from provided source code"
#build images and leverage ACR build engine to build the containers
az acr build --registry $loginName --image tta/web:1.0 -f 'containers/TTA.Web.dockerfile' 'src/'
az acr build --registry $loginName --image tta/webclient:1.0 -f 'containers/TTA.Web.ClientApi.dockerfile' 'src/'
az acr build --registry $loginName --image tta/sql:1.0 -f 'containers/TTA.DataGenerator.SQL.dockerfile' 'src/'
az acr build --registry $loginName --image tta/statgen:1.0 -f 'containers/TTA.StatGenerator.dockerfile' 'src/'
Write-Host "Images built and prepped"

# create SQL server, SQL database and deploy database
Set-Location "/scripts/IaC/Modernization/"
Write-Host "Install Azure SQL"
$currentServer = az deployment group create --resource-group $rgName --template-file sql.bicep --parameters sql.parameters.json | ConvertFrom-Json
$server = $currentServer.properties.outputs.loginServer.value
Write-Host "Azure SQL $server installed, adding rules to access it"
#add your current IP to the access rule
$ip = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
Write-Host "Adding $ip to SQL FW rules"
az sql server firewall-rule create --server $server --resource-group $rgName --name AllowYourIp --start-ip-address $ip --end-ip-address $ip
#allow azure services to be able to access
az sql server firewall-rule create --resource-group $rgName --server $server --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
Write-Host "Adding FW rules for accessing the cluster done"

# get values to build connection string
$username = $currentServer.properties.outputs.loginName.value
$password = $currentServer.properties.outputs.loginPass.value
$dbName = $currentServer.properties.outputs.dbName.value
Write-Host "Getting connection string from $server and using DB $dbName"

# check connectivity to SQL server
$sqlConnection = az sql db show-connection-string --client ado.net --server $server
$sqlConnection = $sqlConnection.replace('<username>', $username)
$sqlConnection = $sqlConnection.replace('<password>', $password)
$sqlConnection = $sqlConnection.replace('<databasename>', $dbName)
Write-Host "ConnectionString has been set to $sqlConnection"

Write-Host "Doing an import of bacpac file"
# key is valid for 1 day - need to refresh it or call 
# az storage blob generate-sas --account-name nameofstorageaccount -c ama -n TTADB.bacpac --permissions r --expiry 2022-01-01T00:00:00Z
az sql db import -s $server -n $dbName --storage-key-type SharedAccessKey --storage-uri "https://webeudatastorage.blob.core.windows.net/ama/TTADB.bacpac" -g $rgName -p $password -u $username --storage-key "?sv=2021-04-10&st=2022-09-07T17%3A48%3A00Z&se=2022-09-09T17%3A48%3A47Z&sr=b&sp=r&sig=do3agVkOd8uQp4IJAj9HJNgGZg0HM8ZJX9%2B%2FMulqR2k%3D"
Write-Host "Import done."
Write-Host "Create container app environment $containerappenv in $regionToDeploy "
az containerapp env create --name $containerappenv --resource-group $rgName --location $regionToDeploy
Write-Host "Environment $containerappenv created, going to create container app to be used with containers"
$registryServer = "$loginName.azurecr.io"
$imageName = "$registryServer/tta/web:1.0"

#get ACR pass
$acrPass = az acr credential show -n $loginName --query passwords[0].value
Write-Host "Using $imageName to generate container app in environment $containerappenv"
$fqdn = az containerapp create --max-replicas 3 --env-vars SqlOptions__ConnectionString=$sqlConnection --registry-server $registryServer --registry-username $loginName --registry-password $acrPass --name $containerAppName --resource-group $rgName --environment $containerappenv --image $imageName --target-port 80 --ingress 'external' --query properties.configuration.ingress.fqdn
Write-Host "Container app running at $fqdn, starting app"

 