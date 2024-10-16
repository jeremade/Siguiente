param databaseName string

@description('The name for the container')
param containerName string

@description('The partition key for the container')
param partitionKeys array

@description('The throughput policy for the container')
@allowed([
  'Manual'
  'Autoscale'
])
param throughputPolicy string = 'Autoscale'

@description('Time to Live for data in analytical store. (-1 no expiry)')
@minValue(-1)
@maxValue(2147483647)
param analyticalStoreTTL int = -1

@description('Throughput value when using Manual Throughput Policy for the container')
@minValue(400)
@maxValue(1000000)
param manualProvisionedThroughput int = 400

@description('Maximum throughput when using Autoscale Throughput Policy for the container')
@minValue(1000)
@maxValue(1000000)
param autoscaleMaxThroughput int = 1000

var throughput_Policy = {
  Manual: {
    throughput: manualProvisionedThroughput
  }
  Autoscale: {
    autoscaleSettings: {
      maxThroughput: autoscaleMaxThroughput
    }
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' existing = {
  name: databaseName
}

var partitionKeyKind = length(partitionKeys) == 1 ? 'Hash' : 'MultiHash'

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-05-15' = {
  name: containerName
  parent: database
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: partitionKeys
        kind: partitionKeyKind
        version: 2
      }
      analyticalStorageTtl: analyticalStoreTTL
    }
    options: throughput_Policy[throughputPolicy]
  }
}
