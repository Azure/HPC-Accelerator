targetScope = 'resourceGroup'

param prefix string
param location string = resourceGroup().location

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${prefix}-mi'
  location: location
}

output principalId string = mi.properties.principalId
