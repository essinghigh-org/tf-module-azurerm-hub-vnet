resource "azurerm_virtual_network_gateway" "vnet_gw" {
  count = var.create_expressroute_gateway && var.subnets.gateway.enabled ? 1 : 0

  resource_group_name = var.rg_name
  location            = var.location

  name = "${var.vnet_name}-vng"
  type = "ExpressRoute"
  sku  = var.gateway_sku

  remote_vnet_traffic_enabled = false
  virtual_wan_traffic_enabled = false

  ip_configuration {
    name      = "vnetGatewayConfig"
    subnet_id = azurerm_subnet.gw_subnet[0].id

    private_ip_address_allocation = "Dynamic"
  }

  timeouts {
    create = "60m"
    delete = "60m"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      vpn_type
    ]
  }
}

resource "azurerm_virtual_network_gateway_connection" "exp_rt_conn" {
  for_each = var.create_expressroute_gateway && var.subnets.gateway.enabled ? var.express_route_circuit_id : {}

  resource_group_name = var.rg_name
  location            = var.location

  name           = "${var.vnet_name}-connect-${each.key}"
  routing_weight = each.value.routing_weight
  type           = "ExpressRoute"

  virtual_network_gateway_id = azurerm_virtual_network_gateway.vnet_gw[0].id
  express_route_circuit_id   = each.value.id
  authorization_key          = each.value.authorization_key

  timeouts {
    create = "60m"
    delete = "60m"
  }

  tags = var.tags
}
