locals {
  subnet_nsgs = var.subnets.management.nsg == null || !try(var.subnets.management.nsg.enabled, true) ? {} : {
    management = {
      subnet_id = azurerm_subnet.management_subnet.id
      config    = var.subnets.management.nsg
    }
  }

  subnet_nsg_rules = merge([
    for subnet_key, subnet_nsg in local.subnet_nsgs : {
      for rule in concat(
        !subnet_nsg.config.allow_internet_outbound ? [] : [
          {
            key                          = "${subnet_key}.allow_internet_outbound"
            subnet_key                   = subnet_key
            name                         = "AllowInternetOutbound"
            priority                     = 110
            direction                    = "Outbound"
            access                       = "Allow"
            protocol                     = "*"
            source_port_range            = "*"
            source_port_ranges           = null
            destination_port_range       = "*"
            destination_port_ranges      = null
            source_address_prefix        = "*"
            source_address_prefixes      = null
            destination_address_prefix   = "Internet"
            destination_address_prefixes = null
          }
        ],
        [
          for rule_name, rule in subnet_nsg.config.rules : {
            key                          = "${subnet_key}.${rule_name}"
            subnet_key                   = subnet_key
            name                         = rule_name
            priority                     = 200 + index(sort(keys(subnet_nsg.config.rules)), rule_name)
            direction                    = rule.direction
            access                       = "Allow"
            protocol                     = rule.protocol
            source_port_range            = rule.source_port_range == null && rule.source_port_ranges == null ? "*" : rule.source_port_range
            source_port_ranges           = rule.source_port_ranges
            destination_port_range       = rule.destination_port_range == null && rule.destination_port_ranges == null ? "*" : rule.destination_port_range
            destination_port_ranges      = rule.destination_port_ranges
            source_address_prefix        = rule.source_address_prefix == null && rule.source_address_prefixes == null ? "*" : rule.source_address_prefix
            source_address_prefixes      = rule.source_address_prefixes
            destination_address_prefix   = rule.destination_address_prefix == null && rule.destination_address_prefixes == null ? "*" : rule.destination_address_prefix
            destination_address_prefixes = rule.destination_address_prefixes
          }
        ],
        [
          {
            key                          = "${subnet_key}.deny_all_inbound"
            subnet_key                   = subnet_key
            name                         = "DenyAllInbound"
            priority                     = 4096
            direction                    = "Inbound"
            access                       = "Deny"
            protocol                     = "*"
            source_port_range            = "*"
            source_port_ranges           = null
            destination_port_range       = "*"
            destination_port_ranges      = null
            source_address_prefix        = "*"
            source_address_prefixes      = null
            destination_address_prefix   = "*"
            destination_address_prefixes = null
          },
          {
            key                          = "${subnet_key}.deny_all_outbound"
            subnet_key                   = subnet_key
            name                         = "DenyAllOutbound"
            priority                     = 4096
            direction                    = "Outbound"
            access                       = "Deny"
            protocol                     = "*"
            source_port_range            = "*"
            source_port_ranges           = null
            destination_port_range       = "*"
            destination_port_ranges      = null
            source_address_prefix        = "*"
            source_address_prefixes      = null
            destination_address_prefix   = "*"
            destination_address_prefixes = null
          }
        ]
      ) : rule.key => rule
    }
  ]...)
}

resource "azurerm_network_security_group" "subnet" {
  for_each = local.subnet_nsgs

  name                = "${azurerm_virtual_network.az_vnet.name}-${each.key}-nsg"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = {
      for rule_key, rule in local.subnet_nsg_rules : rule_key => rule
      if rule.subnet_key == each.key
    }

    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range
      source_port_ranges           = security_rule.value.source_port_ranges
      destination_port_range       = security_rule.value.destination_port_range
      destination_port_ranges      = security_rule.value.destination_port_ranges
      source_address_prefix        = security_rule.value.source_address_prefix
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefix   = security_rule.value.destination_address_prefix
      destination_address_prefixes = security_rule.value.destination_address_prefixes
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet" {
  for_each = local.subnet_nsgs

  subnet_id                 = each.value.subnet_id
  network_security_group_id = azurerm_network_security_group.subnet[each.key].id
}
