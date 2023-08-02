data "azurerm_subnet" "env_subnet"{
  # name = "{{ envParams.networkSubnet }}"
  name = "DA-BPASB-SRV_LAN"
  virtual_network_name = data.azurerm_virtual_network.env_virtual_network.name
  resource_group_name  = var.net_resource_group_name
}

data "azurerm_virtual_network" "env_virtual_network" {
  resource_group_name = var.net_resource_group_name
  # name                = "{{ envParams.networkName }}"
  name                = "DA-BPASB-NET"
}