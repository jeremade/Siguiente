param name string
param location string
param tags object
param azureCliVersion string = '2.9.1'
param env array = []
param script string = 'echo "Hello Worlds"'
param arguments string = ''

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: name
  location: location
  tags: tags
  kind: 'AzureCLI'
  properties: {
    azCliVersion: azureCliVersion
    arguments: arguments
    environmentVariables: env
    scriptContent: script
    cleanupPreference: 'OnExpiration'
    retentionInterval: 'PT1H'
  }
}

output env array = deploymentScript.properties.environmentVariables
