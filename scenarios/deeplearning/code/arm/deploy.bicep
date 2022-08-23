targetScope = 'resourceGroup'

@description('The type of replication to use for the Location.')
@allowed([
  'westeurope'
  'eastus'
  'eastus2'
  'westus'
  'centralus'
])
param location string = 'westeurope'

@description('The organization directory to use.')
param tenantId string = tenant().tenantId

@description('This application should be contributor role in this subscription.')
param applicationId string

@description('This applicationSecret should be this application')
@secure()
param applicationSecret string

@description('Azure National Cloud to use.')
@maxLength(36)
@allowed([
  'public'
  'china'
  'germany'
  'usgov'
])
param azureSovereignCloud string = 'public'

@maxLength(12)
param prefix string
param virtualMachineSize string
param adminUsername string

@secure()
param adminPassword string
param ccScriptFilePath string = 'https://raw.githubusercontent.com/Azure/HPC-Accelerator/main/scenarios/deeplearning/code/arm/script/ccloud_install.py'

var nicName = '${prefix}-ni'
var nsgName = '${prefix}-nsg'
var vnetName = '${prefix}-vnet'
var pipName = '${prefix}-ip'
var vmName = '${prefix}-vm'
var uniqueResourceNameBase = uniqueString(resourceGroup().id, location, deployment().name)
var tagName = 'dlId'
var tags = {
  '${tagName}': uniqueResourceNameBase
}

resource nic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: nicName
  tags: tags
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
            properties: {
              deleteOption: 'Detach'
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: nsgName
  tags: tags
  location: location
  properties: {
    securityRules: [
      {
        name: 'HTTPS'
        properties: {
          priority: 1010
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceApplicationSecurityGroups: []
          destinationApplicationSecurityGroups: []
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '443'
        }
      }
      {
        name: 'HTTP'
        properties: {
          priority: 1020
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceApplicationSecurityGroups: []
          destinationApplicationSecurityGroups: []
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'default-allow-ssh'
        properties: {
          priority: 1030
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceApplicationSecurityGroups: []
          destinationApplicationSecurityGroups: []
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  tags: tags
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.8.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.8.0.0/24'
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: pipName
  tags: tags
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-07-01' = {
  name: vmName
  tags: tags
  location: location
  plan: {
    name: 'cyclecloud8'
    publisher: 'azurecyclecloud'
    product: 'azure-cyclecloud'
  }
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'azurecyclecloud'
        offer: 'azure-cyclecloud'
        sku: 'cyclecloud8'
        version: 'latest'
      }
      dataDisks: [for j in range(0, 1): {
        lun: 0
        createOption: 'fromImage'
        caching: 'None'
        diskSizeGB: null
        managedDisk: {
          id: null
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
        writeAcceleratorEnabled: false
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Delete'
          }
        }
      ]
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        patchSettings: {
          patchMode: 'ImageDefault'
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource customScriptExt 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: vm
  name: 'CustomScript'
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {
      commandToExecute: 'python ccloud_install.py --azureSovereignCloud "${azureSovereignCloud}" --tenantId "${tenantId}" --applicationId "${applicationId}" --applicationSecret "${applicationSecret}" --username "${adminUsername}" --hostname "${vmName}" --password "${adminPassword}" --acceptTerms'
        fileUris: [
          '${ccScriptFilePath}'
        ]
    }
  }
}


//output adminUsername string = adminUsername
//output excuteScript string = 'sudo python /home/${adminUsername}/AzureCycleCloudArmTemplate/script/ccloud_install.py --azureSovereignCloud ${azureSovereignCloud} --tenantId ${tenantId} --applicationId ${applicationId} --applicationSecret ${applicationSecret} --username ${adminUsername} --hostname ${virtualMachineName_var} --password ${adminPassword} --acceptTerms'
//@description('Refer : https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-8.1.0')
//output removeResourcesUsingPS string = 'Get-AzResource -TagName "${tagName}" -TagValue "${uniqueResourceNameBase}" | Remove-AzResource -force'
