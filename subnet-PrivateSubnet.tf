resource "azurerm_subnet" "private_subnet" {
  name                            = "PrivateSubnet"
  resource_group_name             = var.rg_name
  virtual_network_name            = azurerm_virtual_network.az_vnet.name
  address_prefixes                = [var.subnets.private.cidr]
  default_outbound_access_enabled = var.subnets.private.default_outbound_access_enabled
}
