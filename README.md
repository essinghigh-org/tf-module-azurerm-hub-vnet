# tf-module-azurerm-hub-vnet

Creates an Azure hub VNet from explicit inputs. The module does not derive a VNet name, allocate subnet CIDRs, or create a default subnet layout: callers provide the VNet name, address space, and standard subnet configuration.

It supports the four standard hub subnet slots (`gateway`, `management`, `public`, and `private`), additional delegated subnets, an optional management-subnet NSG, an optional public route table, and an optional ExpressRoute gateway with circuit connections.
