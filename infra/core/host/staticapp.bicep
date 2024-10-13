param name string
param tags object
param appName string

resource staticWebApp 'Microsoft.Web/staticSites@2022-09-01' = {
  name: name
  location: 'eastus2'
  tags: tags
  sku: {
    name: 'Dedicated'
    tier: 'Dedicated'
  }
  kind: 'string'
  properties: {
    allowConfigFileUpdates: false
    buildProperties: {
      appLocation: join(['/apps', appName], '/')
      apiLocation: ''
      appArtifactLocation: ''
    }
    repositoryUrl: 'https://github.com/jeremade/Siguiente'
    branch: 'main'
    stagingEnvironmentPolicy: 'Enabled'
  }
}
