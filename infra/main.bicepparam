using './main.bicep'

param environmentName = readEnvironmentVariable('AZURE_ENV_NAME', 'dev')
param location = readEnvironmentVariable('AZURE_LOCATION', 'eastus2')
param vmCloudflarePrivateKey = readEnvironmentVariable('AZURE_CF_PRIVATE_KEY', '')
param useVirtualNetworkIntegration = bool(readEnvironmentVariable('USE_VIRTUAL_NETWORK_INTEGRATION', 'true'))
param useVirtualNetworkPrivateEndpoint = bool(readEnvironmentVariable('USE_VIRTUAL_NETWORK_PRIVATE_ENDPOINT', 'true'))
param virtualNetworkAddressSpacePrefix = readEnvironmentVariable('VIRTUAL_NETWORK_ADDRESS_SPACE_PREFIX', '10.1.0.0/16')
param virtualNetworkIntegrationSubnetAddressSpacePrefix = readEnvironmentVariable('VIRTUAL_NETWORK_INTEGRATION_SUBNET_ADDRESS_SPACE_PREFIX', '10.1.1.0/24')
param virtualNetworkPrivateEndpointSubnetAddressSpacePrefix = readEnvironmentVariable('VIRTUAL_NETWORK_PRIVATE_ENDPOINT_SUBNET_ADDRESS_SPACE_PREFIX', '10.1.2.0/24')
