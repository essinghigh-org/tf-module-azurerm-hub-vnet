locals {
  standard_subnet_names = toset([
    "GatewaySubnet",
    "ManagementSubnet",
    "PublicSubnet",
    "PrivateSubnet",
  ])
}

resource "azurerm_virtual_network" "az_vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.vnet_cidr
  dns_servers         = var.dns_servers
  tags                = var.tags

  lifecycle {
    precondition {
      condition = alltrue([
        for subnet_name in keys(var.additional_subnets) :
        !contains(local.standard_subnet_names, subnet_name)
      ])
      error_message = "additional_subnets cannot reuse the names of the standard hub subnets."
    }
  }
}
