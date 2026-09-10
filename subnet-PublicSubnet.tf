resource "azurerm_subnet" "public_subnet" {
  name                            = "PublicSubnet"
  resource_group_name             = var.rg_name
  virtual_network_name            = azurerm_virtual_network.az_vnet.name
  address_prefixes                = [var.subnets.public.cidr]
  default_outbound_access_enabled = var.subnets.public.default_outbound_access_enabled
}
