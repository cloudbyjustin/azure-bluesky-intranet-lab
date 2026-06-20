param location string = 'eastus'
param rgName string = 'rg-bluesky'
param vnetName string = 'vnet-bluesky'
param adminUsername string = 'azureuser'
param adminPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-web'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'subnet-mgmt'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.3.0/27'
        }
      }
    ]
  }
}

resource st 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'stblueskylogs'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {}
}

resource nsgWeb 'Microsoft.Network/networkSecurityGroups@2023-05-01' = {
  name: 'nsg-web'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP'
        properties: {
          priority: 100
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '80'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
      {
        name: 'Allow-SSH'
        properties: {
          priority: 110
          access: 'Allow'
          direction: 'Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource subnetWebNsg 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  name: '${vnet.name}/subnet-web'
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: nsgWeb.id
    }
  }
}

resource pipVm 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-web01'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nicVm 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: 'nic-web01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: pipVm.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: 'vm-web01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'vm-web01'
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '22_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nicVm.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        storageUri: 'https://${st.name}.blob.core.windows.net/'
      }
    }
  }
}

resource pipLb 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-lb-web'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource lb 'Microsoft.Network/loadBalancers@2023-05-01' = {
  name: 'lb-web'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'fe-web'
        properties: {
          publicIPAddress: {
            id: pipLb.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'bp-web'
      }
    ]
    probes: [
      {
        name: 'hp-http'
        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/'
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'lbr-http'
        properties: {
          frontendIPConfiguration: {
            id: lb.properties.frontendIPConfigurations[0].id
          }
          backendAddressPool: {
            id: lb.properties.backendAddressPools[0].id
          }
          probe: {
            id: lb.properties.probes[0].id
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          loadDistribution: 'Default'
        }
      }
    ]
  }
}

resource bastionPip 'Microsoft.Network/publicIPAddresses@2023-05-01' = {
  name: 'pip-bastion'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastion 'Microsoft.Network/bastionHosts@2023-05-01' = {
  name: 'bastion-bluesky'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'bastion-ipconfig'
        properties: {
          subnet: {
            id: vnet.properties.subnets[2].id
          }
          publicIPAddress: {
            id: bastionPip.id
          }
        }
      }
    ]
  }
}
