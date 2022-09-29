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


@maxValue(600)
@minValue(0)
@description('Number of seconds to wait for Azure to colsolidate the new roleAssignment before continuing with the deployment of the custom script extension.')
param secondsToWaitBeforeCustomScriptExec int = 180

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
param virtualMachineSize string = 'Standard_D2s_v4'
param adminUsername string

@secure()
param adminPassword string

var contributorRoleDefinitionId = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var rgName = '${prefix}-rg'
var uniqueResourceNameBase = uniqueString(subscription().id, location, tenantId, prefix)
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
    principalId: mi.outputs.principalId
    roleDefinitionId: tenantResourceId('Microsoft.Authorization/roleDefinitions', contributorRoleDefinitionId)
    principalType: 'ServicePrincipal'
  }
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
    secondsToWaitBeforeCustomScriptExec: secondsToWaitBeforeCustomScriptExec
    tags: tags
    tenantId: tenantId
    virtualMachineSize: virtualMachineSize
  }
  dependsOn: [ra]
}
