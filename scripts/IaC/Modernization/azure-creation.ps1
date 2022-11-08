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
# Version 0.5.1
# SHORT CHANGE DESCRIPTION: adding function support to prettify the output
#>
param(
    [string]$regionToDeploy="westeurope",
    [string]$rgName="rg-cust-ama-ce-2",
    [string]$workDir="C:/Work/Projects/azure-monitor-automation-wth",
    [string]$acrName="acramacustomerlist",
    [string]$containerappenv="ama-cust-env-containers",
    [string]$containerapp="ama-cust-containers-tta-web"
)

function CreateResourceGroup($rgName,$regionToDeploy){
    Write-host "Setting $workDir as working directory and moving to modernization folder"    
    Write-Host "Creating resource group $rgName in $regionToDeploy"
    az deployment sub create --location $regionToDeploy --template-file rg.bicep --parameters resourceGroupName=$rgName resourceGroupLocation=$regionToDeploy
    Write-Host "Resource group $rgName created (or updated)"
}

function RegistryDeploy($rgName, $regionToDeploy,$acrName) {
    Write-Host "Creating registry $acrName in $regionToDeploy"
    if ($acrName -eq "") {
        $acrName = "acr$(-join ((65..90) + (97..122) | Get-Random -Count 5 | % {[char]$_}))"
    }
    az deployment group create --resource-group $rgName --template-file registry.bicep --parameters acrName=$acrName
    Write-Host "Done with creating registry"
    $loginName=az acr show --name $acrName --query loginServer --output tsv
    Write-Host "Created registry is $loginName"   
}

function BuildAndDeployImages($workDir, $loginName)
{
    Write-host "Setting $workDir as working directory"
    Set-Location "$workDir"
    Write-Host "Building images from provided source code to $loginName"
    #build images and leverage ACR build engine to build the containers
    az acr build --registry $loginName --image tta/web:1.0 -f 'containers/TTA.Web.dockerfile' 'src'
    az acr build --registry $loginName --image tta/webclient:1.0 -f 'containers/TTA.Web.ClientApi.dockerfile' 'src'
    az acr build --registry $loginName --image tta/sql:1.0 -f 'containers/TTA.DataGenerator.SQL.dockerfile' 'src'
    az acr build --registry $loginName --image tta/statgen:1.0 -f 'containers/TTA.StatGenerator.dockerfile' 'src'
    Write-Host "Images built and prepped - setting back to script modernization"
    Set-Location "$workDir/scripts/IaC/Modernization"
}

function CreateSqlAndAddFwRules($rgName)
{    
    Write-Host "Install Azure SQL"
    $currentServer=az deployment group create --resource-group $rgName --template-file sql.bicep --parameters sql.parameters.json | ConvertFrom-Json
    # what you put in the parameters file is what you get back
    $sqlParameters=Get-Content sql.parameters.json | ConvertFrom-Json | Select-Object -ExpandProperty parameters
    $sqlServerName=$sqlParameters | Select-Object -ExpandProperty serverName
    Write-Host "SQL Server name is $($sqlServerName.value)"
    $Env:AMA_SQLServer_NAME = $sqlServerName.value
    Write-Host "Azure SQL $server installed, adding rules to access it"
    #add your current IP to the access rule
    $ip = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
    Write-Host "Adding $ip to SQL FW rules"
    az sql server firewall-rule create --server $server --resource-group $rgName --name AllowYourIp --start-ip-address $ip --end-ip-address $ip
    #allow azure services to be able to access
    az sql server firewall-rule create --resource-group $rgName --server $server --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
    Write-Host "Adding FW rules for accessing the cluster done, setting conn string"
    $username = $sqlParameters | Select-Object -ExpandProperty administratorLogin
    $Env:AMA_SQLServer_Username = $username.value
    $password = $sqlParameters | Select-Object -ExpandProperty administratorLoginPassword
    $Env:AMA_SQLServer_PWD = $password.value
    $dbName = $sqlParameters | Select-Object -ExpandProperty sqlDBName
    Write-Host "Getting connection string from $server and using DB $($dbName.value)"
    # get connection string from SQL server
    $sqlConnection=az sql db show-connection-string --client ado.net --server $sqlServerName.value
    $sqlConnection=$sqlConnection.replace('<username>', $username.value)
    $sqlConnection=$sqlConnection.replace('<password>', $password.value)
    $sqlConnection=$sqlConnection.replace('<databasename>', $dbName.value)
    Write-Host "ConnectionString has been set to $sqlConnection"
    $Env:AMA_SQLServerConn=$sqlConnection
}

function ImportDataToSql($rgName)
{
    Write-Host "Doing an import of bacpac file"
    $server = $Env:AMA_SQLServer_NAME
    $password = $Env:AMA_SQLServer_Username
    $username = $Env:AMA_SQLServer_NAME
    # az storage blob generate-sas --account-name nameofstorageaccount -c ama -n TTADB.bacpac --permissions r --expiry 2022-01-01T00:00:00Z
    az sql db import -s $server -n $dbName --storage-key-type SharedAccessKey --storage-uri "https://webeudatastorage.blob.core.windows.net/ama/TTADB.bacpac" -g $rgName -p $password -u $username --storage-key "?sv=2021-04-10&st=2022-11-07T07%3A57%3A00Z&se=2023-01-01T07%3A57%3A00Z&sr=b&sp=r&sig=MvPfn1rNRdzX2sESe23f5H2R0IpUTKgs79B8%2FRarzSY%3D"
}

function CreateContainerEnvWithApp($containerappenv, $containerAppName, $regionToDeploy, $rgName, $loginName)
{
    Write-Host "Create container app environment $containerappenv in $location "
    az containerapp env create --name $containerappenv --resource-group $rgName --location $location
    Write-Host "Environment $containerappenv created, going to create container app"
    $registryServer = "$loginName.azurecr.io"
    $imageName = "$registryServer/tta/web:1.0"
    $acrPass = az acr credential show -n $loginName --query passwords[0].value
    Write-Host "Using $imageName to generate container app in environment $containerappenv"
    $sqlConn=$Env:AMA_SQLServerConn
    Write-Host "Using $sqlConn as connection string"
    $fqdn = az containerapp create --max-replicas 3 --env-vars SqlOptions__ConnectionString=$sqlConn --registry-server $registryServer --registry-username $loginName --registry-password $acrPass --name $containerAppName --resource-group $rgName --environment $containerappenv --image $imageName --target-port 80 --ingress 'external' --query properties.configuration.ingress.fqdn
    Write-Host "Container app running at $fqdn, starting web browser"
    Start-Process "microsoft-edge:'$fqdn'"
}
# write log to Temp file
Start-Transcript -Path "C:\temp\deploy.log"
# go to IaC script folder
Set-Location "$workDir/scripts/IaC/Modernization"
# 0. Create resource group
CreateResourceGroup -rgName $rgName -regionToDeploy $regionToDeploy
# 1. Deploy registry
RegistryDeploy -rgName $rgName -regionToDeploy $regionToDeploy -acrName $acrName
# 2. Build images
# BuildAndDeployImages -workDir $workDir -loginName $acrName
# 3. Create SQL and add FW rules
CreateSqlAndAddFwRules -rgname $rgName
# 4. import data to SQL
# ImportDataToSql -rgName $rgName
# 5. Create container app env with container app and open browser 
$fqdn = CreateContainerEnvWithApp -containerappenv $containerappenv -containerAppName $containerapp -regionToDeploy $regionToDeploy -rgName $rgName -loginName $acrName

Stop-Transcript