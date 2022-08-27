targetScope = 'subscription'

@description('The type of replication to use for the location.')
// @allowed([
//   'westeurope'
//   'eastus'
//   'eastus2'
//   'westus'
//   'centralus'
// ])
param location string = deployment().location

@description('The organization directory to use.')
param tenantId string = tenant().tenantId

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

var contributorRoleDefinitionId = '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
var rgName = '${prefix}-rg'
var uniqueResourceNameBase = uniqueString(subscription().id, location, deployment().name)
var tagName = 'dlId'
var tags = {
  '${tagName}': uniqueResourceNameBase
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module mi 'deploy.managedidentity.bicep' = {
  name: '${uniqueResourceNameBase}-mi'
  scope: rg
  params: {
    prefix: prefix
    location: location
  }
}

resource ra 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(uniqueResourceNameBase)
  properties: {
    principalId: miexisting.properties.principalId
    roleDefinitionId: contributorRoleDefinitionId
    principalType: 'ServicePrincipal'
  }
}

resource miexisting 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: '${prefix}-mi'
  scope: rg
}

module vm 'deploy.vm.bicep' = {
  scope: rg
  name: '${uniqueResourceNameBase}-vm'
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    azureSovereignCloud: azureSovereignCloud
    location: location
    prefix: prefix
    tags: tags
    tenantId: tenantId
    virtualMachineSize: virtualMachineSize
  }
  dependsOn: [ra]
}
