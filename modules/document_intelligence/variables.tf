variable "name" {
  description = "Name of the Document Intelligence (Cognitive Services) account."
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

variable "sku_name" {
  description = "SKU. S0 (standard) supports private endpoints; F0 (free) does not."
  type        = string
  default     = "S0"
}

variable "custom_subdomain_name" {
  description = "Custom subdomain (required for private endpoint + Entra ID auth). Defaults to the lowercased account name."
  type        = string
  default     = ""
}

variable "local_auth_enabled" {
  description = "Allow API-key (local) auth in addition to Entra ID. Set false to require Entra ID only."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

# ---------- Networking ----------
variable "private_endpoint_subnet_id" {
  description = "Subnet ID where the private endpoint is created."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "IDs of the EXISTING private DNS zone(s) for Cognitive Services (privatelink.cognitiveservices.azure.com)."
  type        = list(string)
}

# ---------- Diagnostics ----------
variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for diagnostic settings."
  type        = string
}

# ---------- RBAC ----------
variable "role_principal_ids" {
  description = "Principal (object) IDs granted the data role - typically the managed identity."
  type        = list(string)
  default     = []
}

variable "role_definition_name" {
  description = "Built-in role granted to role_principal_ids on the account."
  type        = string
  default     = "Cognitive Services User"
}
