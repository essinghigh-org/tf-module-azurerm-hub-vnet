resource "azurerm_subnet" "additional" {
  for_each = var.additional_subnets

  name                            = each.key
  resource_group_name             = var.rg_name
  virtual_network_name            = azurerm_virtual_network.az_vnet.name
  address_prefixes                = each.value.address_prefixes
  default_outbound_access_enabled = each.value.default_outbound_access_enabled

  dynamic "delegation" {
    for_each = each.value.delegations

    content {
      name = delegation.key

      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}
