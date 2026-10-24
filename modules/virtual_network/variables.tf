variable "name" {
  description = "Name of the virtual network."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "address_space" {
  description = "VNet address space (CIDR list)."
  type        = list(string)
}

variable "dns_servers" {
  description = "Custom DNS servers (empty = Azure-provided DNS)."
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = "Map of subnets to create (key = subnet name)."
  type = map(object({
    address_prefixes                  = list(string)
    delegation                        = optional(string, null) # e.g. "Microsoft.Web/serverFarms"
    service_endpoints                 = optional(list(string), [])
    private_endpoint_network_policies = optional(string, "Disabled")
    security_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    })), [])
  }))
}

variable "log_analytics_workspace_id" {
  description = "Optional Log Analytics workspace ID for NSG diagnostics. Null = no NSG diagnostics (avoids a cycle when the workspace depends on this VNet)."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
