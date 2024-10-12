param ipv4AddressName string
param location string
param tags object

resource ipv4 'Microsoft.Network/publicIPAddresses@2024-01-01' = {
  name: ipv4AddressName
  location: location
  tags: tags
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}

output publicIpV4 string = ipv4.properties.ipAddress
