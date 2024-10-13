param location string
param networkInterfaceName string
param subnetId string

param publicIpAddressName string

param virtualMachineName string
param virtualMachineComputerName string

param adminUsername string

param tags object

@secure()
param tunnelToken string
@secure()
param sshPrivateKey string
@secure()
param vmCloudflarePassword string

resource networkInterface 'Microsoft.Network/networkInterfaces@2024-01-01' = {
  name: 'network-interface'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: networkInterfaceName
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName)
            properties: {
              deleteOption: 'Detach'
            }
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: virtualMachineName
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
          id: networkInterface.id
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
      computerName: virtualMachineComputerName
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
