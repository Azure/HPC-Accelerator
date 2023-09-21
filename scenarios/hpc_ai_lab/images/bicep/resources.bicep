
@description('Location of all resources')
param location string = resourceGroup().location
param namePrefix string

var tenantId = subscription().tenantId

//deploy the batch account
resource batchAccount 'Microsoft.Batch/batchAccounts@2023-05-01' = {
  name: 'batch${namePrefix}'
  location: location
  properties: {
    publicNetworkAccess: 'Enabled'
    poolAllocationMode: 'BatchService'
    allowedAuthenticationModes: [
      'AAD'
      'SharedKey'
      'TaskAuthenticationToken'
    ]
    networkProfile: {
      accountAccess: {
        defaultAction: 'Allow'
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
  tags: {}
  dependsOn: []
}

//deploy a storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: 'storage${namePrefix}'
  location: location
  properties: {
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    defaultToOAuthAuthentication: false
    accessTier: 'Hot'
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
    }
    dnsEndpointType: 'Standard'
    encryption: {
      keySource: 'Microsoft.Storage'
      services: {
        blob: {
          enabled: true
        }
        file: {
          enabled: true
        }
      }
      requireInfrastructureEncryption: false
    }
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  tags: {}
  dependsOn: []
}
//ensure soft delete isn't enabled on blobs so this can be deleted when we're through (this is a lab config)
resource storageAccountName_default 'Microsoft.Storage/storageAccounts/blobServices@2022-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    restorePolicy: {
      enabled: false
    }
    deleteRetentionPolicy: {
      enabled: false
    }
    containerDeleteRetentionPolicy: {
      enabled: false
    }
    changeFeed: {
      enabled: false
    }
    isVersioningEnabled: false
  }
}
//ensure soft delete isn't enabled on files so this can be deleted when we're through (this is a lab config)
resource Microsoft_Storage_storageAccounts_fileservices_storageAccountName_default 'Microsoft.Storage/storageAccounts/fileservices@2022-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: false
    }
  }
  dependsOn: [

    storageAccountName_default
  ]
}
//create a keyvault to link to AML
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: 'kvaltlu${namePrefix}'
  location: location
  
  properties: {
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
  }
}
//create a log analytics workspace to link to AML
resource appInsightsLogWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: 'logAnalytics${namePrefix}'
  location: location
}
//link the AML workspace to the la worksapce
resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  location: location
  name: 'appInsights${namePrefix}'
  kind: 'web'
  properties: {    
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaMachineLearningExtension'
    WorkspaceResourceId: appInsightsLogWorkspace.id
  }
}
//create a container registry for AML
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: 'acr${namePrefix}'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}
//Create the AML workspace
resource workspace 'Microsoft.MachineLearningServices/workspaces@2022-12-01-preview' = {
  name: 'amllu${namePrefix}'
  location: location
  kind: 'Default'
  identity: {
    type: 'systemAssigned'
  }
  sku: {
    tier: 'Basic'
    name: 'Basic'
  }
  properties: {
    friendlyName: 'aml${namePrefix}'
    description: 'levelup workspace'
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: applicationInsights.id
    containerRegistry: containerRegistry.id

    systemDatastoresAuthMode: 'accessKey'
    publicNetworkAccess: 'Enabled'
  }
}
//create a datafactory instance
resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: 'dataFactory${namePrefix}'
  location: location
  properties: {    
    publicNetworkAccess: 'Enabled'    
  }
  identity: {
    type: 'SystemAssigned'
  }
}
//create a managed vnet for the data factory instance
resource dataFactoryManagedVnet 'Microsoft.DataFactory/factories/managedVirtualNetworks@2018-06-01' = {
  parent: dataFactory
  name: 'default'
  properties: {}
}
//create a managed integration runtime for the data factory instance
resource df_AutoResolveIntegrationRuntime 'Microsoft.DataFactory/factories/integrationRuntimes@2018-06-01' = {
  parent: dataFactory
  name: 'AutoResolveIntegrationRuntime'
  properties: {
    type: 'Managed'
    managedVirtualNetwork: {
      referenceName: 'default'
      type: 'ManagedVirtualNetworkReference'
    }
    typeProperties: {
      computeProperties: {
        location: 'AutoResolve'
        dataFlowProperties: {
          computeType: 'General'
          coreCount: 8
          timeToLive: 0
        }
      }
    }
  }
  dependsOn: [
    dataFactoryManagedVnet
  ]
}
//create a vnet for the batch instance with a subnet
resource batchVnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: 'vnet${namePrefix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.150.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'batchsubnet${namePrefix}'
        properties: {
          addressPrefix: '10.150.0.0/24'          
        }
      }
    ]
  }

  resource batchSubnet 'subnets' existing = {
    name: 'batchsubnet${namePrefix}'
  }
}
//create a compute pool on the batch account
resource batchPool 'Microsoft.Batch/batchAccounts/pools@2022-10-01' = {
  name: 'batchpool${namePrefix}'
  parent: batchAccount
  properties: {
    deploymentConfiguration: {
      virtualMachineConfiguration: {        
        imageReference: {
          offer: 'dsvm-win-2019'
          publisher: 'microsoft-dsvm'
          sku: 'winserver-2019'
          version: 'latest'
        }
        licenseType: 'Windows_Server'
        nodeAgentSkuId: 'batch.node.windows amd64'
        nodePlacementConfiguration: {
          policy: 'Regional'
        }
        windowsConfiguration: {
          enableAutomaticUpdates: true
        }
      }
    }
    networkConfiguration: {
      dynamicVnetAssignmentScope: 'none'
      publicIPAddressConfiguration: {
        provision: 'BatchManaged'
      }
      subnetId: batchVnet::batchSubnet.id
    }
    displayName: 'batchpool${namePrefix}'
    interNodeCommunication: 'Disabled'    
    scaleSettings: {
      fixedScale: {
        resizeTimeout: 'PT15M'
        targetDedicatedNodes: 1
        targetLowPriorityNodes: 0
      }
    }
    targetNodeCommunicationMode: 'Default'
    taskSchedulingPolicy: {
      nodeFillType: 'Pack'
    }
    taskSlotsPerNode: 1    
    vmSize: 'STANDARD_D2S_V3'
  }
}
//crate a linked service in data factory for the storage account
resource df_ls_storage 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'df_ls_storage_${namePrefix}'
  parent: dataFactory
  properties: {
    type: 'AzureBlobStorage'
    annotations: []
    typeProperties: {
      connectionString: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value}'
    }
  }
}
//creat a linked service for the batch account in data factory
resource df_ls_batch 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  name: 'df_ls_batch_${namePrefix}'
  parent: dataFactory
  properties: {
    annotations: []
    type: 'AzureBatch'
    description: 'Azure Batch Linked Service'
    typeProperties: {
      batchUri: 'https://${batchAccount.properties.accountEndpoint}/'
      poolName: batchPool.name
      accountName: batchAccount.name
      linkedServiceName: {
        referenceName: df_ls_storage.name
        type: 'LinkedServiceReference'
      }

      accessKey: {
        type: 'SecureString'
        value: batchAccount.listKeys().primary
      }
    }

    connectVia: {
      parameters: {}
      referenceName: df_AutoResolveIntegrationRuntime.name
      type: 'IntegrationRuntimeReference'
    }
  }
}
