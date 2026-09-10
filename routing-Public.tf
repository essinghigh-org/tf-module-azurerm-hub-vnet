resource "azurerm_route_table" "public_rt" {
  count = var.subnets.public.route_table_enabled ? 1 : 0

  resource_group_name = var.rg_name
  location            = var.location
  name                = "${var.vnet_name}-public-route-table"

  bgp_route_propagation_enabled = false

  route {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "public_route" {
  count = var.subnets.public.route_table_enabled ? 1 : 0

  subnet_id      = azurerm_subnet.public_subnet[0].id
  route_table_id = azurerm_route_table.public_rt[0].id
}
