targetScope = 'resourceGroup'

param adminUsername string
param azureSovereignCloud string
param location string
param prefix string
param tags object
param tenantId string = tenant().tenantId
param virtualMachineSize string
@maxValue(600)
@minValue(0)
param secondsToWaitBeforeCustomScriptExec int = 180

@secure()
param adminPassword string

var uniqueResourceNameBase = uniqueString(subscription().id, resourceGroup().id, location, deployment().name)
var nicName = '${prefix}-ni'
var nsgName = '${prefix}-nsg'
var vnetName = '${prefix}-vnet'
var pipName = '${prefix}-ip'
var vmName = '${prefix}-vm'
var storageAccountName = uniqueResourceNameBase

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
            id: defaultSubnet.id
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
        name: 'vnet-allow-ssh'
        properties: {
          priority: 1030
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceApplicationSecurityGroups: []
          destinationApplicationSecurityGroups: []
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' = {
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
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.8.1.0/24'
        }
      }
    ]
  }
}

resource defaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: vnet
  name: 'default'
}

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: vnet
  name: 'AzureBastionSubnet'
}

resource pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: pipName
  tags: tags
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    dnsSettings: {
      domainNameLabel: prefix
    }
  }
}

resource pipBastion 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: '${pipName}-bastion'
  tags: tags
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: '${prefix}-mi'
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
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${mi.id}': {}
    }
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
            deleteOption: 'Detach'
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
      customData: loadFileAsBase64('../cloud-init/cloud-init.yaml')
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2022-01-01' = {
  name : '${prefix}-bastion'
  location: location
  properties: {
    enableTunneling: true
    ipConfigurations: [
      {
        name: 'ipconf'
        properties: {
          subnet: {
            id: bastionSubnet.id
          }
          publicIPAddress: {
            id: pipBastion.id
          }
        }
      }
    ]
  }
  sku: {
    name: 'Standard'
  }
}

resource customScriptExt 'Microsoft.Compute/virtualMachines/extensions@2022-03-01' = {
  parent: vm
  location: location
  name: 'CustomScript'
  properties: {
    publisher: 'Microsoft.Azure.Extensions'
    type: 'CustomScript'
    typeHandlerVersion: '2.0'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {
      commandToExecute: 'while [ ! -f /root/ccloud_install.py ]; do echo "WARN: /root/ccloud_install.py not present, sleeping for 5s"; sleep 5; done; sleep ${secondsToWaitBeforeCustomScriptExec}; python3 /root/ccloud_install.py --azureSovereignCloud "${azureSovereignCloud}" --tenantId "${tenantId}" --username "${adminUsername}" --hostname "${pip.properties.dnsSettings.fqdn}" --password "${adminPassword}" --storageAccount ${storageAccountName} --resourceGroup ${resourceGroup().name} --useManagedIdentity --acceptTerms --useLetsEncrypt --webServerPort 80 --webServerSslPort 443 --webServerMaxHeapSize 4096M'
      fileUris: []
    }
  }
}

output fqdn string = pip.properties.dnsSettings.fqdn
