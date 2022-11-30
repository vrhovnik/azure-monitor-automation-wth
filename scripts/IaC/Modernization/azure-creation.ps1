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
# Version 0.6.2
# SHORT CHANGE DESCRIPTION: added app insight to be created and to be added as env to containers
#>
param(
    [string]$regionToDeploy = "westeurope",
    [string]$rgName = "rg-cust-ama-ce-2",
    [string]$workDir = "C:/Work/Projects/azure-monitor-automation-wth",
    [string]$sqlServerName = "amadatattasqlserver",
    [string]$sqlServerUsername = "ttauser",
    [string]$sqlServerPwd = "ttauser123!",
    [string]$acrName = "acramacustomerlist",
    [string]$containerappenv = "ama-cust-env",
    [string]$containerapp = "ama-cust-containers-tta-web"
)

function CreateResourceGroup($rgName, $regionToDeploy)
{
    Write-host "Setting $workDir as working directory and moving to modernization folder"
    Write-Host "Creating resource group $rgName in $regionToDeploy"
    az deployment sub create --location $regionToDeploy --template-file rg.bicep --parameters resourceGroupName=$rgName resourceGroupLocation=$regionToDeploy
    Write-Host "Resource group $rgName created (or updated)"
}

function RegistryDeploy($rgName, $regionToDeploy, $acrName)
{
    Write-Host "Creating registry $acrName in $regionToDeploy"
    if ($acrName -eq "")
    {
        $acrName = "acr$( -join ((65..90) + (97..122) | Get-Random -Count 5 | % { [char]$_ }) )"
    }
    az deployment group create --resource-group $rgName --template-file registry.bicep --parameters acrName=$acrName
    Write-Host "Done with creating registry"
    $loginName = az acr show --name $acrName --query loginServer --output tsv
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
    Write-Host "Images built and prepped - setting back folder to script modernization"
    Set-Location "$workDir/scripts/IaC/Modernization"
}

function CreateSqlAndAddFwRules($rgName,$sqlName,$sqlUsername,$sqlPassword)
{
    Write-Host "Install Azure SQL"
    az deployment group create --resource-group $rgName --template-file sql.bicep --parameters serverName=$sqlName administratorLoginPassword=$sqlPassword administratorLogin=$sqlUsername
    Write-Host "SQL Server name is $sqlName"
    $Env:AMA_SQLServer_NAME = $sqlName
    Write-Host "Azure SQL $server installed, adding rules to access it"
    #add your current IP to the access rule
    $ip = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
    Write-Host "Adding $ip to SQL FW rules"
    az sql server firewall-rule create --server $sqlName --resource-group $rgName --name AllowYourIp --start-ip-address $ip --end-ip-address $ip
    #allow azure services to be able to access
    az sql server firewall-rule create --resource-group $rgName --server $sqlName --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
    Write-Host "Adding FW rules for accessing the cluster done, setting conn string"
    $Env:AMA_SQLServer_Username = $sqlUsername
    $Env:AMA_SQLServer_PWD = $sqlPassword
    Write-Host "Getting connection string from $sqlName and using TTADB"
    # get connection string from SQL server
    $sqlConnection = az sql db show-connection-string --client ado.net --server $sqlServerName.value
    $sqlConnection = $sqlConnection.replace('<username>', $sqlUsername)
    $sqlConnection = $sqlConnection.replace('<password>', $sqlPassword)
    $sqlConnection = $sqlConnection.replace('<databasename>', 'TTADB')
    Write-Host "ConnectionString has been set to $sqlConnection"
    $Env:AMA_SQLServerConn = $sqlConnection
}

function ImportDataToSql($rgName)
{
    Write-Host "Doing an import of bacpac file"
    $server = $Env:AMA_SQLServer_NAME
    $password = $Env:AMA_SQLServer_PWD
    $username = $Env:AMA_SQLServer_Username
    # az storage blob generate-sas --account-name nameofstorageaccount -c ama -n TTADB.bacpac --permissions r --expiry 2022-01-01T00:00:00Z
    az sql db import -s $server -n TTADB --storage-key-type SharedAccessKey --storage-uri "https://webeudatastorage.blob.core.windows.net/ama/TTADB.bacpac" -g $rgName -p $password -u $username --storage-key "?sv=2021-04-10&st=2022-11-07T07%3A57%3A00Z&se=2023-01-01T07%3A57%3A00Z&sr=b&sp=r&sig=MvPfn1rNRdzX2sESe23f5H2R0IpUTKgs79B8%2FRarzSY%3D"
}

function InstallApplicationInsights($rgName, $lawName, $aiName)
{
    Write-Host "Installing (or updating) Application Insights $aiName based on workspace $lawName"
    az deployment group create --resource-group $rgName --template-file appinsights.bicep --parameters  workspaceName=$lawName applicationInsightsName=$aiName
    Write-Host "Application Insights $aiName installed, setting environment variables AMA_AI_CONN_STRING"
    $aidata = az monitor app-insights component show --app $aiName --resource-group $rgName | ConvertFrom-Json
    $Env:AMA_AI_CONN_STRING = $aidata.connectionString
}

function CreateContainerEnvWithApp($containerappenv, $containerAppName, $regionToDeploy, $rgName, $loginName)
{
    Write-Host "Create container app environment $containerappenv in $regionToDeploy "
    az containerapp env create --name $containerappenv --resource-group $rgName --location $regionToDeploy
    Write-Host "Environment $containerappenv created, going to create container app $containerAppName"
    $registryServer = "$loginName.azurecr.io"
    $imageName = "$registryServer/tta/web:1.0"
    $acrPass = az acr credential show -n $loginName --query passwords[0].value
    Write-Host "Using $imageName to generate container app in environment $containerappenv"
    $sqlConn = $Env:AMA_SQLServerConn
    Write-Host "Using $sqlConn as connection string for environment variable"
    $fqdn = az containerapp create --max-replicas 3 --env-vars SqlOptions__ConnectionString = $sqlConn --registry-server $registryServer --registry-username $loginName --registry-password $acrPass --name $containerAppName --resource-group $rgName --environment $containerappenv --image $imageName --target-port 80 --ingress 'external' --query properties.configuration.ingress.fqdn
    Write-Host "Container app running at $fqdn, starting web browser"
    Start-Process "$fqdn"
}

function CreateContainerEnvWithBicep($containerappenv, $containerAppName, $regionToDeploy, $rgName, $registryName)
{
    Write-Host "Create container app environment $containerappenv in $regionToDeploy"
    $sqlConnection = $Env:AMA_SQLServerConn
    Write-Host "Using $sqlConnection as connection string for environment variable for SQL connection string"
    $registryServer = "$registryName.azurecr.io"
    $imageName = "$registryServer/tta/web:1.0"
    Write-Host "Using $imageName to generate container app in environment $containerappenv"
    $aiConnString = $Env:AMA_AI_CONN_STRING
    Write-Host "Using $aiConnString as connection string for environment variable for application insight"
    $fqdn = az deployment group create --template-file "containerapp.bicep" --resource-group $rgName --parameters containerAppName=$containerAppName containerAppEnvName=$containerappenv location=$regionToDeploy containerImage=$imageName sqlConn=$sqlConnection containerRegistryName=$registryName aiConn=$aiConnString | ConvertFrom-Json
    $createdFQDN = $fqdn.properties.outputs.containerAppFQDN.value
    Write-Host "Container app running at $createdFQDN, starting web browser"
    Start-Process "msedge.exe" -ArgumentList $createdFQDN
}

# write log to Temp file
Start-Transcript
# go to IaC script folder
Set-Location "$workDir/scripts/IaC/Modernization"
# 0. Create resource group
CreateResourceGroup -rgName $rgName -regionToDeploy $regionToDeploy
# 1. Deploy registry
RegistryDeploy -rgName $rgName -regionToDeploy $regionToDeploy -acrName $acrName
# 2. Build images
BuildAndDeployImages -workDir $workDir -loginName $acrName
# 3. Create SQL and add FW rules
CreateSqlAndAddFwRules -rgname $rgName -sqlName $sqlServerName -sqlUsername $sqlServerUsername -sqlPassword $sqlServerPwd
# 4. import data to SQL
ImportDataToSql -rgName $rgName
# 5. Install Application Insights
$lawName = "law-$containerapp" #define name for the container app
$aiName = "ai-$containerapp" # specify name for application insights
InstallApplicationInsights -rgName $rgName -lawName $lawName -aiName $aiName
# 6. Create container app env with container app and open browser 
CreateContainerEnvWithBicep -containerappenv $containerappenv -containerAppName $containerapp -regionToDeploy $regionToDeploy -rgName $rgName -registryName $acrName
# checks logs for any challenges
Stop-Transcript