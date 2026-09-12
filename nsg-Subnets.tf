# Subnet NSGs, built on the shared subnet-nsg module.
#
# The management subnet keeps its opinionated shape (Allow-only custom
# rules with automatic priorities over deny-all backstops); the inputs
# are translated onto profiles plus explicit rules. Additional subnets
# get the full generic engine: profiles list plus caller-owned rules.

locals {
  management_nsg_config  = var.subnets.management.nsg
  management_nsg_enabled = local.management_nsg_config != null && try(local.management_nsg_config.enabled, true)
  management_rule_names  = sort(keys(try(local.management_nsg_config.rules, {})))

  management_custom_rules = {
    for name in local.management_rule_names : name => merge(
      {
        priority = 200 + index(local.management_rule_names, name)
        access   = "Allow"
      },
      local.management_nsg_config.rules[name],
    )
  }

  management_profiles = concat(
    try(local.management_nsg_config.allow_internet_outbound, false) ? ["allow_internet_outbound"] : [],
    ["deny_all"],
  )
}

module "management_nsg" {
  source  = "terraform.essinghigh.dev/essinghigh-org/subnet-nsg/azurerm"
  version = "0.1.1"
  count   = local.management_nsg_enabled ? 1 : 0

  name                = "${azurerm_virtual_network.az_vnet.name}-management-nsg"
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = azurerm_subnet.management_subnet.id
  profiles            = local.management_profiles
  rules               = local.management_custom_rules
  tags                = var.tags
}

module "additional_subnet_nsg" {
  source  = "terraform.essinghigh.dev/essinghigh-org/subnet-nsg/azurerm"
  version = "0.1.1"
  for_each = {
    for key, subnet in var.additional_subnets : key => subnet
    if try(subnet.nsg, null) != null && try(subnet.nsg.enabled, true)
  }

  name                = coalesce(try(each.value.nsg.name, null), "${azurerm_virtual_network.az_vnet.name}-${each.key}-nsg")
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = azurerm_subnet.additional[each.key].id
  profiles            = try(each.value.nsg.profiles, [])
  rules               = try(each.value.nsg.rules, {})
  tags                = var.tags
}
