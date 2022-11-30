@description('Specifies the name of the container app.')
param containerAppName string = 'app-${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the container app environment.')
param containerAppEnvName string = 'env-${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the log analytics workspace.')
param containerAppLogAnalyticsName string = 'ama-law-${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the container registry.')
param containerRegistryName string = 'cr${uniqueString(resourceGroup().id)}'

@description('Specifies the location for all resources.')
@allowed([
  'westeurope'
  'eastus'
  'northeurope'  
])
param location string

@description('Specifies the docker container image to deploy.')
param containerImage string = 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'

@description('Specifies the SQL conn.')
param sqlConn string = 'Server=tcp:xxxxx.database.windows.net,1433;Database=TTADB;User ID=ttasql;Encrypt=true;Connection Timeout=30;'

@description('Application Insights connection string')
param aiConn string = 'InstrumentationKey=00000000-0000-0000-0000-000000000000;EndpointSuffix=ai.contoso.com;'

@description('Minimum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param minReplica int = 1

@description('Maximum number of replicas that will be deployed')
@minValue(0)
@maxValue(25)
param maxReplica int = 3

param resourceTags object = {
  Description: 'automation-monitor-what-the-hack'
  Environment: 'Demo'
}

var acrPullRole = resourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: containerAppLogAnalyticsName
  location: location
  tags: resourceTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-06-01-preview' = {
  name: containerAppEnvName
  location: location
  sku: {
    name: 'Consumption'
  }
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalytics.properties.customerId
        sharedKey: logAnalytics.listKeys().primarySharedKey
      }
    }
  }
}

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'id-${containerAppName}'
  location: location
}

@description('This allows the managed identity of the container app to access the registry, note scope is applied to the wider ResourceGroup not the ACR')
resource uaiRbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, uai.id, acrPullRole)
  properties: {
    roleDefinitionId: acrPullRole
    principalId: uai.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource containerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
  name: containerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uai.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 80
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
      registries: [
        {
          identity: uai.id
          server: '${containerRegistryName}.azurecr.io'
        }
      ]
    }
    template: {
      revisionSuffix: 'firstrevision'
      containers: [
        {
          name: containerAppName
          image: containerImage
          env: [
                 {
                   name: 'SqlOptions__ConnectionString'
                   value: sqlConn
                 }
                 {
                   name: 'ApplicationInsights__ConnectionString'
                   value: aiConn
                 }
          ]
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: minReplica
        maxReplicas: maxReplica
        rules: [
          {
           name: 'cpu-scaling-rule'
           custom: {
             type: 'cpu'
             metadata: {
               type: 'Utilization'
               value: '10'
               }
             }
           }
        ]
      }
    }
  }
}

output containerAppFQDN string = containerApp.properties.configuration.ingress.fqdn