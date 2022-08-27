targetScope = 'resourceGroup'

param prefix string
param location string = resourceGroup().location
var contributorRoleDefinitionId = '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${prefix}-mi'
  location: location
}

resource ra 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: mi
  name: guid(subscription().id, uniqueString(resourceGroup().id))
  properties: {
    principalId: mi.properties.principalId
    roleDefinitionId: contributorRoleDefinitionId
    principalType: 'ServicePrincipal'
  }
}
