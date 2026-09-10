resource "azurerm_subnet" "gw_subnet" {
  count = var.subnets.gateway.enabled ? 1 : 0

  name                            = "GatewaySubnet"
  resource_group_name             = var.rg_name
  virtual_network_name            = azurerm_virtual_network.az_vnet.name
  address_prefixes                = [var.subnets.gateway.cidr]
  default_outbound_access_enabled = var.subnets.gateway.default_outbound_access_enabled
}
