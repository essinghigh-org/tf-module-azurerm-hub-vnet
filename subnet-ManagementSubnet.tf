resource "azurerm_subnet" "management_subnet" {
  name                            = "ManagementSubnet"
  resource_group_name             = var.rg_name
  virtual_network_name            = azurerm_virtual_network.az_vnet.name
  address_prefixes                = [var.subnets.management.cidr]
  default_outbound_access_enabled = var.subnets.management.default_outbound_access_enabled
}
