variable "name" {
  description = "Name of the storage account (3-24 lowercase alphanumeric)."
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

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Replication type (LRS, ZRS, GRS, ...)."
  type        = string
  default     = "LRS"
}

variable "account_kind" {
  description = "Storage account kind."
  type        = string
  default     = "StorageV2"
}

variable "shared_access_key_enabled" {
  description = "Allow access-key auth. Prefer false (Entra ID only) where the workload supports it."
  type        = bool
  default     = true
}

variable "containers" {
  description = "Blob containers to create."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

# ---------- Networking ----------
variable "private_endpoint_subnet_id" {
  description = "Subnet ID where the blob private endpoint is created."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "IDs of the EXISTING private DNS zone(s) for blob (privatelink.blob.core.windows.net)."
  type        = list(string)
}

# ---------- Diagnostics ----------
variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for diagnostic settings."
  type        = string
}

# ---------- RBAC ----------
variable "role_principal_ids" {
  description = "Principal (object) IDs granted Storage Blob Data Contributor - typically the managed identity."
  type        = list(string)
  default     = []
}
