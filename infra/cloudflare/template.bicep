param location string
param networkInterfaceName1 string
param networkInterfaceName2 string
param networkInterfaceName3 string
param subnetId string

param publicIpAddressName1 string

param virtualMachineName1 string
param virtualMachineComputerName1 string

param adminUsername string
param virtualMachineName2 string
param virtualMachineComputerName2 string
param virtualMachineName3 string
param virtualMachineComputerName3 string

param tags object

@secure()
param sshPrivateKey string
@secure()
param vmCloudflarePassword string

resource networkInterface1 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: networkInterfaceName1
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName1)
            properties: {
              deleteOption: 'Detach'
            }
          }
        }
      }
    ]
  }
}

resource networkInterface2 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: networkInterfaceName2
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig2'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName1)
            properties: {
              deleteOption: 'Detach'
            }
          }
        }
      }
    ]
  }
}

resource networkInterface3 'Microsoft.Network/networkInterfaces@2022-11-01' = {
  name: networkInterfaceName3
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig3'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName1)
            properties: {
              deleteOption: 'Detach'
            }
          }
        }
      }
    ]
  }
}

resource virtualMachine1 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: virtualMachineName1
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A1_v2'
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'cloudflare'
        offer: 'cloudflare_tunnel_vm'
        sku: 'cloudflare_tunnel_vm'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface1.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    securityProfile: {}
    additionalCapabilities: {
      hibernationEnabled: false
    }
    osProfile: {
      computerName: virtualMachineComputerName1
      adminUsername: adminUsername
      adminPassword: vmCloudflarePassword
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  plan: {
    name: 'cloudflare_tunnel_vm'
    publisher: 'cloudflare'
    product: 'cloudflare_tunnel_vm'
  }
  zones: ['1']
}

resource virtualMachine2 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: virtualMachineName2
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A1_v2'
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'cloudflare'
        offer: 'cloudflare_tunnel_vm'
        sku: 'cloudflare_tunnel_vm'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface2.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    securityProfile: {}
    additionalCapabilities: {
      hibernationEnabled: false
    }
    osProfile: {
      computerName: virtualMachineComputerName2
      adminUsername: adminUsername
      adminPassword: vmCloudflarePassword
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  plan: {
    name: 'cloudflare_tunnel_vm'
    publisher: 'cloudflare'
    product: 'cloudflare_tunnel_vm'
  }
  zones: ['2']
}

resource virtualMachine3 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: virtualMachineName3
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_A1_v2'
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        deleteOption: 'Delete'
      }
      imageReference: {
        publisher: 'cloudflare'
        offer: 'cloudflare_tunnel_vm'
        sku: 'cloudflare_tunnel_vm'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface3.id
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    securityProfile: {}
    additionalCapabilities: {
      hibernationEnabled: false
    }
    osProfile: {
      computerName: virtualMachineComputerName3
      adminUsername: adminUsername
      adminPassword: vmCloudflarePassword
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
  plan: {
    name: 'cloudflare_tunnel_vm'
    publisher: 'cloudflare'
    product: 'cloudflare_tunnel_vm'
  }
  zones: ['3']
}

// resource activateRoot 'Microsoft.Compute/virtualMachines/runCommands@2024-07-01' = {
//   parent: ubuntuVM
//   name: 'ActivateRootWithSSH'
//   location: resourceGroup().location
//   properties:{
//     protectedParameters: [
//       {
//         name: 'ROOTPW'
//         value: adminPassword
//       }
//     ]
//     errorBlobUri: 'https://<STORAGE ACCOUNT>.blob.core.windows.net/<CONTAINER>/error.txt?<SAS TOKEN>'
//     outputBlobUri: 'https://<STORAGE ACCOUNT>.blob.core.windows.net/<CONTAINER>/output.txt?<SAS TOKEN>'
//     source:{
//       script: '''
//         sudo passwd -u root && sudo echo "root:$ROOTPW" | chpasswd && echo "root pw changed" \
//         sudo echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && sudo service ssh reload && echo "ssh restarted"
//       '''
//     }
//   }
// }
