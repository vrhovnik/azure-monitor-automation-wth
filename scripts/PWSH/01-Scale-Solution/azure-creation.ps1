########################################################################################################################
## if you didn't do Move to IaaS part at 
# https://github.com/vrhovnik/azure-monitor-automation-wth/blob/main/docs/01-move-to-IaaS-Azure.md 
# check it out and create initial resources
########################################################################################################################
$rgName="SCALERG"
# FOR EXAMPLE - creating contributor on resources
# az ad sp create-for-rbac -n "<Unique SP Name>" --role "Contributor" --scopes /subscriptions/$subscriptionId
#$appId=""
#$appClientSecret=""
#$tenantId=""

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
#login to azure via service principal

#Write-Header "Az CLI Login"
# az login --service-principal --username $appId --password $appClientSecret --tenant $tenantId

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

Write-Host "Create load balancer and n machines with correct connection string"
az deployment group create --resource-group $rgName --template-file create-vm.bicep --parameters create-vm.parameters.json
 


