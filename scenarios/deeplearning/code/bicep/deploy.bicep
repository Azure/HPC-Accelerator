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

module vm 'deploy.vm.bicep' = {
  scope: rg
  name: uniqueResourceNameBase
  params: {
    adminPassword: adminPassword
    adminUsername: adminUsername
    applicationId: applicationId
    applicationSecret: applicationSecret
    azureSovereignCloud: azureSovereignCloud
    location: location
    prefix: prefix
    tags: tags
    tenantId: tenantId
    virtualMachineSize: virtualMachineSize
  }
}

output fqdn string = vm.outputs.fqdn
