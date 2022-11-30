@description('Name of the workspace where the data will be stored.')
param workspaceName string = 'ama-law'

@description('Name of the application insights resource.')
param applicationInsightsName string = 'ama-ai'

@description('Location for all resources.')
param location string = resourceGroup().location

param resourceTags object = {
  Description: 'automation-and-monitor-what-the-hack'
  Environment: 'Demo'
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: workspaceName
  location: location
  tags: resourceTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: applicationInsightsName
  location: location
  tags: resourceTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: workspace.id
  }
}