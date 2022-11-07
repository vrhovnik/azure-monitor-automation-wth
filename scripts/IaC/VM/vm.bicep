﻿@description('The name of your Virtual Machine')
param vmName string = 'tta-vm-2022'

@description('Username for the Virtual Machine')
param windowsAdminUsername string = 'ttauser'

@description('Password for Windows account. Password must have 3 of the following: 1 lower case character, 1 upper case character, 1 number, and 1 special character. The value must be between 8 and 40 characters long')
@minLength(8)
@maxLength(40)
@secure()
param windowsAdminPassword string

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version')
param windowsOSVersion string = '2022-datacenter-g2'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Name for the IP')
param publicIpAddressName string = 'tta-public-access'

param resourceTags object = {
  Description: 'automation-and-monitor-what-the-hack'
  Environment: 'Demo'
}

var networkInterfaceName = '${vmName}-NIC'
var networkSecurityGroupName = '${vmName}-NSG'
var vnetName = '${vmName}-VNET'
var osDiskType = 'Premium_LRS'

var vnetConfig = {
  vnetprefix: '10.0.0.0/21'
  subnet: {
    name: 'front'
    addressPrefix: '10.0.0.0/24'
  }  
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
  name: vnetName
  tags: resourceTags  
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetConfig.vnetprefix
      ]
    }
    subnets: [
      {
        name: vnetConfig.subnet.name
        properties: {
          addressPrefix: vnetConfig.subnet.addressPrefix
          networkSecurityGroup: {
             id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-03-01' = {
  name: networkSecurityGroupName
  location: location  
  tags: resourceTags
  properties: {
    securityRules: [
      {
        name: 'allow_RDP'
        properties: {
          priority: 1003
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }      
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2021-03-01' = {
  name: networkInterfaceName
  location: location  
  tags: resourceTags
  properties: {
      ipConfigurations: [
        {
          name: 'ipconfig1'
          properties: {
            subnet: {
              id: '${vnet.id}/subnets/front'
            }
            privateIPAllocationMethod: 'Dynamic'
            publicIPAddress: {
                id: publicIpAddress.id
            } 
          }
        }
      ]
    }
}

resource publicIpAddress 'Microsoft.Network/publicIpAddresses@2021-03-01' = {
  name: publicIpAddressName
  location: location  
  tags: resourceTags  
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    idleTimeoutInMinutes: 4
  }
  sku: {
    name: 'Basic'
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location  
  tags: resourceTags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B4ms' 
    }
    storageProfile: {
      osDisk: {
        name: '${vmName}-OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
        diskSizeGB: 1024
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: windowsOSVersion
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: windowsAdminUsername
      adminPassword: windowsAdminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: false
      }
    }
  }
}

resource vmBootstrap 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: vm
  name: 'Bootstrap'
  location: location
  tags: resourceTags
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      fileUris: [
        'https://raw.githubusercontent.com/vrhovnik/azure-monitor-automation-wth/main/scripts/PWSH/00-Move%20to%20IaaS/01-software-install-and-configuration.ps1'
        'https://raw.githubusercontent.com/vrhovnik/azure-monitor-automation-wth/main/scripts/PWSH/00-Move%20to%20IaaS/02-web-db-install.ps1'
      ]
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File 01-software-install-and-configuration.ps1 -adminUsername ${windowsAdminUsername} -scriptPath "https://raw.githubusercontent.com/vrhovnik/azure-monitor-automation-wth/main/scripts/PWSH/00-Move%20to%20IaaS/02-web-db-install.ps1"'
    }
  }
}

output adminUsername string = windowsAdminUsername
output publicIP string = concat(publicIpAddress.properties.ipAddress)
