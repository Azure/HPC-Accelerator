@description('Location of all resources')
param location string 
var namePrefix = uniqueString(subscription().subscriptionId)


targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: '${namePrefix}-rg'
  location: location
}

module resources 'resources.bicep' = {
  name: 'levelupResources'
  scope: rg 
    params: {
      location: location
      namePrefix: namePrefix
    }
}
