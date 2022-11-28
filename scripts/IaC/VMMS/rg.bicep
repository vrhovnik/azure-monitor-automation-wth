targetScope = 'subscription'
@description('Resource Group Name')
param resourceGroupName string = 'rg-ama-vmss'

@description('Resource Group Location')
param resourceGroupLocation string = 'WestEurope'

param resourceTags object = {
  Description: 'automation-and-monitor-what-the-hack'
  Environment: 'Demo'
}

// Creating resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: resourceGroupName 
  tags: resourceTags 
  location: resourceGroupLocation
}

@description('Output resource group name')
output rgName string = resourceGroupName