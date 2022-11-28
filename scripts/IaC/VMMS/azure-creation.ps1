param(
    [string]$regionToDeploy="westeurope",
    [string]$rgName="rg-cust-ama-ce-2",
    [string]$adminName="ttadmin",
    [string]$adminPass="Complic4tedP@ssw0rd1!",
    [string]$workDir="C:/Work/Projects/azure-monitor-automation-wth"
)

function CreateResourceGroup($rgName,$regionToDeploy){
    Write-host "Setting $workDir as working directory and moving to modernization folder"
    Write-Host "Creating resource group $rgName in $regionToDeploy"
    az deployment sub create --location $regionToDeploy --template-file rg.bicep --parameters resourceGroupName=$rgName resourceGroupLocation=$regionToDeploy
    Write-Host "Resource group $rgName created (or updated)"
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
    az sql server firewall-rule create --server $sqlServerName.value --resource-group $rgName --name AllowYourIp --start-ip-address $ip --end-ip-address $ip
    #allow azure services to be able to access
    az sql server firewall-rule create --resource-group $rgName --server $sqlServerName.value --name AllowAzureServices --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
    Write-Host "Adding FW rules for accessing the cluster done, setting conn string"
    $username = $sqlParameters | Select-Object -ExpandProperty administratorLogin
    $Env:AMA_SQLServer_Username = $username.value
    $password = $sqlParameters | Select-Object -ExpandProperty administratorLoginPassword
    $Env:AMA_SQLServer_PWD = $password.value
    $dbName = $sqlParameters | Select-Object -ExpandProperty sqlDBName
    Write-Host "Getting connection string from $($sqlServerName.value) and using DB $($dbName.value)"
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

function CreateVMMS($rgName,$adminName,$adminPass,$numberOfNodes) {
    Write-Host "Starting with deploy"
    az deployment group create --resource-group $rgName --template-file vm.bicep --parameters adminUsername=$adminName adminPassword=$adminPass -numberOfInstances=$numberOfNodes
    Write-Host "Done with VMSS creation"
}

# write log to Temp file
Start-Transcript
# go to IaC script folder
Set-Location "$workDir/scripts/IaC/VMMS"
# 0. Create resource group
CreateResourceGroup -rgName $rgName -regionToDeploy $regionToDeploy
# 1. Create SQL and add FW rules
CreateSqlAndAddFwRules -rgname $rgName
# 4. import data to SQL
ImportDataToSql -rgName $rgName
# 5. Create container app env with container app and open browser 
CreateVMMS -rgName $rgName -adminName $adminName -adminPass $adminPass -numberOfNodes 2
# checks logs for any challenges
Stop-Transcript
