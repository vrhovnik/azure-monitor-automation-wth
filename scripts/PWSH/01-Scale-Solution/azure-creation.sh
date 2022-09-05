########################################################################################################################
## if you didn't do Move to IaaS part at 
# https://github.com/vrhovnik/azure-monitor-automation-wth/blob/main/docs/01-move-to-IaaS-Azure.md 
# check it out and create initial resources
########################################################################################################################
rgName=""
# use what-if to check what will happen to resource group
# https://docs.microsoft.com/en-us/cli/azure/deployment/group?view=azure-cli-latest#az-deployment-group-what-if
az deployment group what-if --resource-group "$rgName" --template-file bootstrap.bicep --parameters bootstrap.parameters.json

# deploy to azure group 
az deployment group create --resource-group "$rgName" --template-file bootstrap.bicep --parameters bootstrap.parameters.json 


