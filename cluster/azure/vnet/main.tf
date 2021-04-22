resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.resource_group.location
  address_space       = [var.address_space]
  resource_group_name = var.resource_group.name
  dns_servers         = var.dns_servers
  tags                = var.tags
}