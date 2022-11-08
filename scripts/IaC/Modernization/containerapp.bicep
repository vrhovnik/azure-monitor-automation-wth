@description('Specifies the name of the container app.')
param containerAppName string = 'containerapp-${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the container app environment.')
param containerAppEnvName string = 'containerapp-env-${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the log analytics workspace.')
param containerAppLogAnalyticsName string = 'containerapp-log-${uniqueString(resourceGroup().id)}'

@description('Specifies the location for all resources.')
@allowed([
  'westeurope'
  'eastus'
  'northeurope'  
])
param location string

@description('Specifies the docker container image to deploy for web')
param frontendContainerImage string = 'mcr.microsoft.com/azuredocs/azure-vote-front:v1'

@description('Specifies the docker container image to deploy for the backend.')
param backendContainerImage string = 'mcr.microsoft.com/dotnet/'

@description('Connection string for Azure SQL Database')
param sqlConn string = 'Server=tcp:myserver.database.windows.net,1433;Database=myDataBase;User ID=mylogin@myserver;Password=myPassword;Trusted_Connection=False;Encrypt=True;'

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

resource containerAppEnv 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: containerAppEnvName
  location: location  
}

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName
  location: location
  tags: resourceTags
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
    }
    template: {
      revisionSuffix: 'firstrevision'
      containers: [
        {
          name: containerAppName
          image: frontendContainerImage
          env: [
            {
              name: 'SqlOptions__ConnectionString'
              value: connString
            }
          ]
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
        }
        {
          name: 'webclient'
          image: backendContainerImage
          env: [
            {
               name: 'SqlOptions__ConnectionString'
               value: connString
            }
          ]
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
        }
      ]      
    }
  }
}

output containerAppFQDN string = containerApp.properties.configuration.ingress.fqdn