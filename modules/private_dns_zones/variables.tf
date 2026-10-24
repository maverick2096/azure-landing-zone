variable "zone_names" {
  description = "Private DNS zone names to create (e.g. privatelink.vaultcore.azure.net)."
  type        = list(string)
}

variable "resource_group_name" {
  description = "Resource group to hold the zones."
  type        = string
}

variable "vnet_links" {
  description = "Map of link key => VNet ID. Every zone is linked to every VNet in this map."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
