output "vnet" {
  description = "Virtual network created by this module."
  value       = azurerm_virtual_network.az_vnet
}

output "subnets" {
  description = "Standard and additional subnets created by this module, keyed by subnet name."
  value = merge(
    {
      ManagementSubnet = azurerm_subnet.management_subnet
      PublicSubnet     = azurerm_subnet.public_subnet
      PrivateSubnet    = azurerm_subnet.private_subnet
    },
    var.subnets.gateway.enabled ? { GatewaySubnet = azurerm_subnet.gw_subnet[0] } : {},
    azurerm_subnet.additional,
  )
}
