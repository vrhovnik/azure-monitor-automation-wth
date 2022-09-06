########################################################################################################################
## if you didn't do Move to IaaS part at 
# https://github.com/vrhovnik/azure-monitor-automation-wth/blob/main/docs/01-move-to-IaaS-Azure.md 
# check it out and create initial resources
########################################################################################################################
rgName="TTARG"

# upgrade to latest version
az bicep upgrade

# check what will be done
az deployment group what-if --resource-group "$rgName" --template-file registry.bicep --parameters registry.parameters.json
# deploy to azure group 
data=az deployment group create --resource-group "$rgName" --template-file registry.bicep --parameters registry.parameters.json 
acrcreds=az acr credential show -n data.loginName --query passwords[0].value

# go to root location - change to root path of your file
rootPath='C:\Work\Projects\azure-monitor-automation-wth\'
Set-Location $rootPath

#build images and leverage ACR build engine to build the containers
az acr build --registry data.loginName --image tta/web:1.0 -f 'containers/TTA.Web.dockerfile' 'src/'
az acr build --registry data.loginName --image tta/webclient:1.0 -f 'containers/TTA.Web.ClientApi.dockerfile' 'src/'
az acr build --registry data.loginName --image tta/sql:1.0 -f 'containers/TTA.DataGenerator.SQL.dockerfile' 'src/'
az acr build --registry data.loginName --image tta/statgen:1.0 -f 'containers/TTA.StatGenerator.dockerfile' 'src/'

# generate keys and store public key for access to node
# https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed

# ssh-keygen -t rsa -b 4096 
# create Kubernetes image and deploy
az deployment group what-if --resource-group "$rgName" --template-file k8s.bicep --parameters k8s.parameters.json
# deploy to azure group 
data=az deployment group create --resource-group "$rgName" --template-file k8s.bicep --parameters k8s.parameters.json

#create Azure SQL
az deployment group what-if --resource-group "$rgName" --template-file sql.bicep --parameters sql.parameters.json
# deploy to azure group 
az deployment group create --resource-group "$rgName" --template-file sql.bicep --parameters sql.parameters.json

Set-Location "$rootPath/src/TTASLN/TTA.DataGenerator.SQL"

#path bin\Release\net6.0\TTA.DataGenerator.SQL.ddl
# check connectivity to SQL server
sqlConn="Data Source="

#prepare ENV parameters to run the database creation and continue
New-Item -Path Env:\SQL_CONNECTION_STRING -Value "$sqlConn;Initial Catalog=master;"
New-Item -Path Env:\FOLDER_ROOT -Value "$rootPath"
New-Item -Path Env:\DROP_DATABASE -Value "false"
New-Item -Path Env:\CREATE_TABLES -Value "true"
New-Item -Path Env:\DEFAULT_PASSWORD -Value "Password123!"
New-Item -Path Env:\RECORD_NUMBER -Value "200"
dotnet run --property:Configuration=Release

# create connection string and populate files
# install kubectl
az aks install-cli
az aks get-credentials --resource-group $rgName --name data.name

# prepare values and replace them via file - you will need a tool to 
Install-Module -Name powershell-yaml -Force
Import-Module powershell-yaml

# go back to root
Set-Location $rootPath

# get yaml file and replace values
data=Get-Content '$rootPath/scripts/PWSH/03-Modernization/02-web.yaml' | ConvertFrom-Yaml

#set image
data.spec.template.spec.containers.image="$(data.loginName).azurecr.io/tta/web:1.0"
data.spec.template.spec.containers.env[0].value="sqlConn"

Set-Content '$rootPath/scripts/PWSH/03-Modernization/02-web.yaml' -Value data

kubectl apply -f .

# set env
k8sResourceGroup="MC_$rgName_$(data.name)_$(data.rgLocation)"
loadBalancer=az resource list --resource-group $k8sResourceGroup --query "[?type=='Microsoft.Network/loadBalancers']"
#get public IP
pipId=$(az network lb show --id $loadBalancer.id --query "frontendIpConfigurations | [?loadBalancingRules != null].publicIpAddress.id" -o tsv)
ip=az network public-ip show --ids $pipId --query "ipAddress" -o tsv

# open solution to see the result
Start-Process "http://$ip"
# setup deployment
