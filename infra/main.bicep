targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

param useVirtualNetworkIntegration bool = false
param useVirtualNetworkPrivateEndpoint bool = false
param virtualNetworkAddressSpacePrefix string = '10.1.0.0/16'
param virtualNetworkIntegrationSubnetAddressSpacePrefix string = '10.1.1.0/24'
param virtualNetworkPrivateEndpointSubnetAddressSpacePrefix string = '10.1.2.0/24'

func tag(resourceId string, contextId string) string => join([resourceId, contextId], '-')

var resourceGroupName = tag('env', environmentName)
var keyVaultName = tag('sigkv', environmentName)
var cosmosName = tag('sig-cosmos', environmentName)

var eventHubServicePrincipalName = tag('eventhub-identity', resourceGroupName)
var deploymentId = guid(tag('deployment', resourceGroupName))

var virtualNetworkName = tag('vnet', resourceGroupName)
var networkSecurityGroupName = tag('nsg', resourceGroupName)
var virtualNetworkIntegrationSubnetName = tag('subnet', resourceGroupName)
var virtualNetworkPrivateEndpointSubnetName = tag('endpoint', resourceGroupName)
var endpointSecurityGroupName = tag('endpoint-nsg', resourceGroupName)

var logAnalyticsName = tag('analytics', environmentName)
var applicationInsigntsName = tag('insights', environmentName)
var dashboardName = tag('dashboard', environmentName)

var tags = {
  'azd-env-name': environmentName
  'deployment-id': deploymentId
}

var useVirtualNetwork = useVirtualNetworkIntegration || useVirtualNetworkPrivateEndpoint

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module cosmosIdentity 'core/security/userAssignedIdentity.bicep' = {
  name: 'cosmos-user-assigned-identity'
  scope: rg
  params: {
    name: tag('identity', cosmosName)
    tags: tags
  }
}

module cosmosRoleAssignment './cosmos/sql/cosmos-sql-role-assign.bicep' = {
  name: 'api-cosmos-access'
  scope: rg
  params: {
    accountName: cosmosDocumentDbAccount.outputs.name
    roleDefinitionId: cosmosRoleDefinition.outputs.id
    principalId: cosmosIdentity.outputs.userPrincipalId
  }
}

module cosmosDocumentDbAccount './cosmos/cosmos-account.bicep' = {
  name: 'cosmos-account'
  scope: rg
  params: {
    name: tag('account', cosmosName)
    tags: tags
    location: location
    keyVaultName: keyVault.outputs.name
    keyVaultIdentity: cosmosIdentity.outputs.name
    kind: 'GlobalDocumentDB'
    locations: [
      {
        locationName: 'Mexico Central'
        failoverPriority: 0
        isZoneRedundant: false
      }
      {
        locationName: 'East US 2'
        failoverPriority: 2
        isZoneRedundant: false
      }
      {
        locationName: 'South Central US'
        failoverPriority: 1
        isZoneRedundant: false
      }
      {
        locationName: 'West US 3'
        failoverPriority: 3
        isZoneRedundant: false
      }
      {
        locationName: 'Spain Central'
        failoverPriority: 4
        isZoneRedundant: false
      }
      {
        locationName: 'Brazil South'
        failoverPriority: 5
        isZoneRedundant: false
      }
    ]
  }
}

module cosmosRoleDefinition './cosmos/sql/cosmos-sql-role-def.bicep' = {
  name: 'cosmos-role-def'
  scope: rg
  params: {
    accountName: cosmosDocumentDbAccount.outputs.name
  }
}

module eventHubUserAssignedIdentity 'core/security/userAssignedIdentity.bicep' = {
  name: 'eventHubServicePrincipal'
  scope: rg
  params: {
    name: eventHubServicePrincipalName
    tags: tags
  }
}

@description('This is the built-in role definition for the Key Vault Secret User role. See https://learn.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-secrets-user for more information.')
resource keyVaultSecretUserRoleDefintion 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  scope: subscription()
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

module keyVaultRoleAssignment 'core/security/role.bicep' = {
  name: 'keyVaultRoleAssignment'
  scope: rg
  params: {
    principalId: eventHubUserAssignedIdentity.outputs.userPrincipalId
    roleDefinitionId: keyVaultSecretUserRoleDefintion.name
    principalType: 'ServicePrincipal'
  }
}

module keyVault 'core/security/keyvault.bicep' = {
  name: 'keyVault'
  scope: rg
  params: {
    name: keyVaultName
    location: location
    tags: tags
    enabledForRbacAuthorization: true
    useVirtualNetworkPrivateEndpoint: useVirtualNetworkPrivateEndpoint
  }
}

module logAnalytics './core/monitor/loganalytics.bicep' = {
  name: 'logAnalytics'
  scope: rg
  params: {
    name: logAnalyticsName
    location: 'eastus2'
    tags: tags
  }
}

module appInsights './core/monitor/applicationinsights.bicep' = {
  name: 'applicationInsights'
  scope: rg
  params: {
    name: applicationInsigntsName
    dashboardName: dashboardName
    location: 'eastus2'
    tags: tags

    includeDashboard: true
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

module integrationSubnetNsg 'core/networking/network-security-group.bicep' = if (useVirtualNetwork) {
  name: 'integrationSubnetNsg'
  scope: rg
  params: {
    name: networkSecurityGroupName
    location: location
  }
}

module privateEndpointSubnetNsg 'core/networking/network-security-group.bicep' = if (useVirtualNetwork) {
  name: 'privateEndpointSubnetNsg'
  scope: rg
  params: {
    name: endpointSecurityGroupName
    location: location
  }
}

module vnet './core/networking/virtual-network.bicep' = if (useVirtualNetwork) {
  name: 'vnet'
  scope: rg
  params: {
    name: virtualNetworkName
    location: location
    tags: tags

    virtualNetworkAddressSpacePrefix: virtualNetworkAddressSpacePrefix

    // TODO: Find a better way to handle subnets. I'm not a fan of this array of object approach (losing Intellisense).
    subnets: [
      {
        name: virtualNetworkIntegrationSubnetName
        addressPrefix: virtualNetworkIntegrationSubnetAddressSpacePrefix
        networkSecurityGroupId: useVirtualNetwork ? integrationSubnetNsg.outputs.id : null
      }
      {
        name: virtualNetworkPrivateEndpointSubnetName
        addressPrefix: virtualNetworkPrivateEndpointSubnetAddressSpacePrefix
        networkSecurityGroupId: useVirtualNetwork ? privateEndpointSubnetNsg.outputs.id : null
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
  }
}
