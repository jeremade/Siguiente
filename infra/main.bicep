targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@secure()
param vmCloudflarePrivateKey string
@secure()
param vmCloudflarePassword string

param useVirtualNetworkIntegration bool = false
param useVirtualNetworkPrivateEndpoint bool = false
param virtualNetworkAddressSpacePrefix string = '10.1.0.0/16'
param virtualNetworkIntegrationSubnetAddressSpacePrefix string = '10.1.1.0/24'
param virtualNetworkPrivateEndpointSubnetAddressSpacePrefix string = '10.1.2.0/24'

func tag(resourceId string, contextId string) string => join([resourceId, contextId], '-')

var resourceGroupName = tag('env', environmentName)
var keyVaultName = tag('sigvault', environmentName)

var userCredential = tag('user-credential', environmentName)
var userCredentialCloudflare = tag('cloudflare', userCredential)

var eventHubServicePrincipalName = tag('eventhub-identity', resourceGroupName)
var deploymentId = guid(tag('deployment', resourceGroupName))

var virtualNetworkName = tag('vnet', resourceGroupName)
var virtualNetworkIpv4 = tag('vnet-ipv4', resourceGroupName)
var networkSecurityGroupName = tag('nsg', resourceGroupName)
var virtualNetworkIntegrationSubnetName = tag('subnet', resourceGroupName)
var virtualNetworkPrivateEndpointSubnetName = tag('endpoint', resourceGroupName)
var endpointSecurityGroupName = tag('endpoint-nsg', resourceGroupName)

var cloudflare = tag('cloudflare', resourceGroupName)
var cloudflare_zone1 = tag(cloudflare, 'zone1')

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

module cloudflareVpnPublicIp 'cloudflare/public.bicep' = {
  name: 'virtualNetworkIpv4'
  scope: rg
  params: {
    ipv4AddressName: virtualNetworkIpv4
    location: location
    tags: tags
  }
}

module cloudflareTunnel 'cloudflare/template.bicep' = {
  name: 'cloudflareTunnel'
  scope: rg
  params: {
    tags: tags
    location: location
    adminUsername: userCredentialCloudflare
    vmCloudflarePassword: vmCloudflarePassword
    subnetId: vnet.outputs.virtualNetworkSubnets[0].id
    sshPrivateKey: vmCloudflarePrivateKey
    publicIpAddressName: virtualNetworkIpv4
    networkInterfaceName: tag('network-interface', cloudflare_zone1)
    virtualMachineName: tag('network-vm', cloudflare_zone1)
    virtualMachineComputerName: tag('computer', cloudflare_zone1)
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
