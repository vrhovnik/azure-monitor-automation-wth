<# 
# SYNOPSIS
# Installs and compile containers, add them to the mix and prepare the container apps
#
# DESCRIPTION
# prepared all neccessary services to host the container images and prepare the 
#
# NOTES
# Author      : Bojan Vrhovnik
# GitHub      : https://github.com/vrhovnik
# Version 0.4.4
# SHORT CHANGE DESCRIPTION: adding description to the script
#>
$rgName = "ContainerRG"
Write-Host "Starting registry deploy in $rgName"
# deploy to azure group 
$data = az deployment group create --resource-group $rgName --template-file registry.bicep --parameters registry.parameters.json
$loginName = $data.properties.outputs.loginName.value
Write-Host "registry created, login aquired $loginName"

Write-Host "Building images"
#build images and leverage ACR build engine to build the containers
az acr build --registry $loginName --image tta/web:1.0 -f 'containers/TTA.Web.dockerfile' 'src/'
az acr build --registry $loginName --image tta/webclient:1.0 -f 'containers/TTA.Web.ClientApi.dockerfile' 'src/'
az acr build --registry $loginName --image tta/sql:1.0 -f 'containers/TTA.DataGenerator.SQL.dockerfile' 'src/'
az acr build --registry $loginName --image tta/statgen:1.0 -f 'containers/TTA.StatGenerator.dockerfile' 'src/'
Write-Host "Images built and prepped"

# create SQL server, SQL database and deploy database
Write-Host "Install Azure SQL"
$currentServer = az deployment group create --resource-group $rgName --template-file sql.bicep --parameters sql.parameters.json
$server = $currentServer.properties.outputs.loginServer.value
Write-Host "Azure SQL $server installed, adding rules to access it"
#add your current IP to the access rule
$ip = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
Write-Host "Adding $ip to SQL FW rules"
az sql server firewall-rule create --server $server --resource-group $rgName --name AllowYourIp --start-ip-address $ip --end-ip-address $ip
#allow azure services to be able to access
az sql server firewall-rule create --resource-group $rgName --server $server --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
Write-Host "Adding FW rules for accessing the cluster done"

# get username
$username = $currentServer.properties.outputs.loginName.value
#get password
$password = $currentServer.properties.outputs.loginPass.value

Write-Host "Getting connection string from $server"

# check connectivity to SQL server
$sqlConnection = az sql db show-connection-string --client ado.net --server $server
$sqlConn = $sqlConnection.replace('<username>', $username)
$sqlConn = $sqlConnection.replace('<password>', $password)
Write-Host "ConnectionString has been set to $sqlConnection"

#prepare ENV parameters to run the database creation and continue
New-Item -Path Env:\SQL_CONNECTION_STRING -Value $sqlConn
New-Item -Path Env:\DROP_DATABASE -Value "false"
New-Item -Path Env:\CREATE_TABLES -Value "true"
New-Item -Path Env:\DEFAULT_PASSWORD -Value "Password123!"
New-Item -Path Env:\RECORD_NUMBER -Value "200"

Write-Host "Populate database"

$location = "WestEurope"
Write-Host "Create container app environment"

$CONTAINERAPPS_ENVIRONMENT = "my-tta-environment"
az containerapp env create --name $CONTAINERAPPS_ENVIRONMENT --resource-group $rgName --location $location
Write-Host "Environment $CONTAINERAPPS_ENVIRONMENT created, going to create container app"
$registryServer = "$loginName.azurecr.io"
$imageName = "$registryServer/tta/web:1.0"
$acrPass = az acr credential show -n $loginName --query passwords[0].value
$containerAppName = "tta-container-web"
Write-Host "Using $imageName to generate environment"
$fqdn = az containerapp create --registry-server $registryServer --registry-username $loginName --registry-password $acrPass --name $containerAppName --resource-group $rgName --environment $CONTAINERAPPS_ENVIRONMENT --image $imageName --target-port 80 --ingress 'external' --query properties.configuration.ingress.fqdn
Write-Host "Container app running at $fqdn, starting app"
#open website on that URL
Start-Process $fqdn
 