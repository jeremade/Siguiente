@description('Azure Cosmos DB account name')
param accountName string = 'sql-${uniqueString(resourceGroup().id)}'

@description('The name for the database')
param databaseName string = 'database1'

resource account 'Microsoft.DocumentDB/databaseAccounts@2022-05-15' existing = {
  name: accountName
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-05-15' = {
  name: databaseName
  parent: account
  properties: {
    resource: {
      id: databaseName
    }
  }
}
