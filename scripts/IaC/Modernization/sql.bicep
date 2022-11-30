﻿@description('The name of the SQL logical server.')
param serverName string = uniqueString('sql', resourceGroup().id)

@description('The name of the SQL Database.')
param sqlDBName string = 'TTADB'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('The administrator username of the SQL logical server.')
param administratorLogin string='ttauser'

@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string

param resourceTags object = {
  Description: 'automation-and-monitor-what-the-hack'
  Environment: 'Demo'
}

resource sqlServer 'Microsoft.Sql/servers@2021-08-01-preview' = {
  name: serverName
  tags: resourceTags 
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2021-08-01-preview' = {
  parent: sqlServer
  name: sqlDBName
  tags: resourceTags 
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

@description('Output the server and creds for access')
output loginServer string = serverName
output loginName string = administratorLogin
output loginPass string = administratorLoginPassword
output dbName string = sqlDBName