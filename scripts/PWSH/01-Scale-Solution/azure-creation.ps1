########################################################################################################################
## if you didn't do Move to IaaS part at 
# https://github.com/vrhovnik/azure-monitor-automation-wth/blob/main/docs/01-move-to-IaaS-Azure.md 
# check it out and create initial resources
########################################################################################################################
$rgName="TTARG"
az deployment group create --resource-group $rgName --template-file bootstrap.bicep --parameters bootstrap.parameters.json
 


