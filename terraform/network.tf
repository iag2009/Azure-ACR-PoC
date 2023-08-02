data "azurerm_virtual_network" "env_virtual_network" {
  name = var.networkName
  resource_group_name = var.net_resource_group_name
}

data "azurerm_subnet" "env_subnet" {
  name                 = var.networkSubnet
  resource_group_name  = var.net_resource_group_name
  virtual_network_name = data.azurerm_virtual_network.env_virtual_network.name
}