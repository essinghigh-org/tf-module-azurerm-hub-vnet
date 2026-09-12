variable "tags" {
  description = "Tags to apply to resources."
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "Azure region for the VNet."
  type        = string
}

variable "rg_name" {
  description = "Resource group where the VNet is deployed."
  type        = string
}

variable "vnet_name" {
  description = "Name of the VNet to create."
  type        = string
}

variable "vnet_cidr" {
  description = "Address spaces for the VNet."
  type        = list(string)
}

variable "dns_servers" {
  description = "DNS servers configured on the VNet."
  type        = list(string)
  default     = null
}

variable "create_expressroute_gateway" {
  description = "Whether to create an ExpressRoute gateway in the GatewaySubnet."
  type        = bool
  default     = false
}

variable "gateway_sku" {
  description = "SKU for the ExpressRoute virtual network gateway."
  type        = string
  default     = "ErGw1AZ"
}

variable "express_route_circuit_id" {
  description = "ExpressRoute circuits to connect to the gateway."
  type = map(object({
    id                = string
    authorization_key = string
    routing_weight    = number
  }))
  default = {}
}

variable "subnets" {
  description = "Configuration for the standard hub subnets. Each enabled subnet requires an explicit CIDR."
  type = object({
    gateway = object({
      cidr                            = string
      enabled                         = optional(bool, true)
      default_outbound_access_enabled = optional(bool, true)
    })
    management = object({
      cidr                            = string
      default_outbound_access_enabled = optional(bool, true)
      nsg = optional(object({
        enabled                 = optional(bool, true)
        allow_internet_outbound = optional(bool, false)
        rules = optional(map(object({
          direction                    = string
          protocol                     = optional(string, "*")
          source_port_range            = optional(string)
          source_port_ranges           = optional(list(string))
          destination_port_range       = optional(string)
          destination_port_ranges      = optional(list(string))
          source_address_prefix        = optional(string)
          source_address_prefixes      = optional(list(string))
          destination_address_prefix   = optional(string)
          destination_address_prefixes = optional(list(string))
        })), {})
      }))
    })
    public = object({
      cidr                            = string
      route_table_enabled             = optional(bool, false)
      default_outbound_access_enabled = optional(bool, true)
    })
    private = object({
      cidr                            = string
      default_outbound_access_enabled = optional(bool, true)
    })
  })
  nullable = false
}

variable "additional_subnets" {
  description = "Additional subnets to create alongside the standard hub subnets."
  type = map(object({
    address_prefixes                = list(string)
    default_outbound_access_enabled = optional(bool, true)
    delegations = optional(map(object({
      name    = string
      actions = list(string)
    })), {})
    nsg = optional(object({
      enabled  = optional(bool, true)
      name     = optional(string)
      profiles = optional(list(string), [])
      rules = optional(map(object({
        priority                                   = number
        direction                                  = string
        access                                     = string
        protocol                                   = optional(string, "*")
        description                                = optional(string)
        source_port_range                          = optional(string)
        source_port_ranges                         = optional(list(string))
        destination_port_range                     = optional(string)
        destination_port_ranges                    = optional(list(string))
        source_address_prefix                      = optional(string)
        source_address_prefixes                    = optional(list(string))
        source_application_security_group_ids      = optional(list(string))
        destination_address_prefix                 = optional(string)
        destination_address_prefixes               = optional(list(string))
        destination_application_security_group_ids = optional(list(string))
      })), {})
    }))
  }))
  default  = {}
  nullable = false
}
