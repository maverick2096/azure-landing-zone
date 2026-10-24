variable "name" {
  description = "Name of the Key Vault."
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

variable "tenant_id" {
  description = "Entra ID tenant ID. Defaults to the current tenant."
  type        = string
  default     = null
}

variable "sku_name" {
  description = "Key Vault SKU (standard or premium)."
  type        = string
  default     = "standard"
}

variable "purge_protection" {
  description = "Enable purge protection."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Soft-delete retention in days (7-90)."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

# ---------- Networking ----------
variable "private_endpoint_subnet_id" {
  description = "Subnet ID where the Key Vault private endpoint is created."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "IDs of the EXISTING private DNS zone(s) for Key Vault (privatelink.vaultcore.azure.net)."
  type        = list(string)
}

variable "network_acls_subnet_ids" {
  description = "Subnet IDs allowed through the Key Vault firewall (service-endpoint based). Optional."
  type        = list(string)
  default     = []
}

# ---------- Diagnostics ----------
variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for diagnostic settings."
  type        = string
}

# ---------- Access policies ----------
variable "access_policy_object_ids" {
  description = "Object (principal) IDs granted data-plane access - typically the managed identity's principal_id."
  type        = list(string)
  default     = []
}

variable "grant_deployer_access" {
  description = "Grant the Terraform deployer identity full management access (needed to seed secrets)."
  type        = bool
  default     = true
}

variable "principal_secret_permissions" {
  description = "Secret permissions granted to access_policy_object_ids."
  type        = list(string)
  default     = ["Get", "List"]
}

variable "principal_key_permissions" {
  description = "Key permissions granted to access_policy_object_ids."
  type        = list(string)
  default     = ["Get", "List"]
}

variable "principal_certificate_permissions" {
  description = "Certificate permissions granted to access_policy_object_ids."
  type        = list(string)
  default     = ["Get", "List"]
}
