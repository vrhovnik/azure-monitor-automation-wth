# LOGIN with SP
# az login --service-principal -u $env:AMA_SP_APPID -p $env:AMA_SP_PASSWORD --tenant $env:AMA_SP_TENANTID
$regionToDeploy="WestEurope"
$rgName="TTARG"
# use what-if to check what will happen to resource group
# https://docs.microsoft.com/en-us/cli/azure/deployment/group?view=azure-cli-latest#az-deployment-group-what-if
az deployment sub what-if --location $regionToDeploy --template-file rg.bicep --parameters rg.parameters.json
az deployment group what-if --resource-group $rgName --template-file vm.bicep --parameters vm.parameters.json