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
param ccScriptFilePath string = 'https://teraweazstorage.blob.${environment().suffixes.storage}/azstorage/initcc.sh?sp=r&st=2022-07-06T08:04:43Z&se=2040-07-06T16:04:43Z&sv=2021-06-08&sr=b&sig=62p8JWBwOFBnn1sq6%2BnjtBn7SjX6omKw%2BMHvoQApeHg%3D'
param ccScriptFileName string = 'initcc.sh'

var nicName = '${prefix}-ni'
var nsgName = '${prefix}-nsg'
var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', nsgName)
var vnetName = '${prefix}-vnet'
var vnetId = resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks', vnetName)
var subnetRef = '${vnetId}/subnets/default'
var publicIpAddressName_var = '${prefix}-ip'
var virtualMachineName_var = '${prefix}-vm'
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
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName_var)
            properties: {
              deleteOption: 'Detach'
            }
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
  dependsOn: [
    nsg
    vnet
    pip
  ]
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
  name: publicIpAddressName_var
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
  name: virtualMachineName_var
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
        deleteOption: 'Detach'
        writeAcceleratorEnabled: false
      }]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName_var
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
      commandToExecute: 'sh ${ccScriptFileName} azureSovereignCloud="${azureSovereignCloud}" tenantId="${tenantId}" applicationId="${applicationId}" applicationSecret="${applicationSecret}" username="${adminUsername}" hostname="${virtualMachineName_var}" password="${adminPassword}"'
        fileUris: [
          '${ccScriptFilePath}'
        ]
    }
  }
}


output adminUsername string = adminUsername
output excuteScript string = 'sudo python /home/${adminUsername}/AzureCycleCloudArmTemplate/script/ccloud_install.py --azureSovereignCloud ${azureSovereignCloud} --tenantId ${tenantId} --applicationId ${applicationId} --applicationSecret ${applicationSecret} --username ${adminUsername} --hostname ${virtualMachineName_var} --password ${adminPassword} --acceptTerms'
@description('Refer : https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-8.1.0')
output removeResourcesUsingPS string = 'Get-AzResource -TagName "${tagName}" -TagValue "${uniqueResourceNameBase}" | Remove-AzResource -force'
