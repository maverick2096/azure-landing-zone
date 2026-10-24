variable "name" {
  description = "Name of the Log Analytics workspace."
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

variable "sku" {
  description = "Workspace SKU."
  type        = string
  default     = "PerGB2018"
}

variable "retention_days" {
  description = "Data retention in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

# ---------- AMPLS / networking ----------
variable "virtual_network_id" {
  description = "VNet ID to link the monitor private DNS zones to."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID where the AMPLS private endpoint is created."
  type        = string
}

variable "ingestion_access_mode" {
  description = "AMPLS ingestion access mode (PrivateOnly or Open)."
  type        = string
  default     = "PrivateOnly"
}

variable "query_access_mode" {
  description = "AMPLS query access mode (PrivateOnly or Open)."
  type        = string
  default     = "PrivateOnly"
}

variable "blob_private_dns_zone_id" {
  description = "Optional existing privatelink.blob.core.windows.net zone ID to include in the AMPLS DNS zone group (agent download path). Reuse the storage module's blob zone to avoid duplicates."
  type        = string
  default     = null
}
