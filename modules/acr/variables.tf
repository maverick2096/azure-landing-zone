variable "name" {
  description = "Name of the container registry (alphanumeric)."
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
  description = "ACR SKU. Must be Premium for private endpoints."
  type        = string
  default     = "Premium"

  validation {
    condition     = var.sku == "Premium"
    error_message = "A private endpoint requires the Premium SKU."
  }
}

variable "admin_enabled" {
  description = "Enable the admin user. Prefer false and use managed-identity AcrPull."
  type        = bool
  default     = false
}

variable "retention_policy_in_days" {
  description = "Untagged manifest retention in days."
  type        = number
  default     = 90
}

variable "trust_policy_enabled" {
  description = "Enable content trust (image signing)."
  type        = bool
  default     = true
}

variable "georeplications" {
  description = "Optional geo-replications. List of objects: { location = string, zone_redundancy_enabled = optional(bool) }."
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool, false)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

# ---------- Networking ----------
variable "private_endpoint_subnet_id" {
  description = "Subnet ID where the registry private endpoint is created."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "IDs of the EXISTING private DNS zone(s) for ACR (privatelink.azurecr.io)."
  type        = list(string)
}

# ---------- Diagnostics ----------
variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for diagnostic settings."
  type        = string
}

# ---------- RBAC ----------
variable "role_principal_ids" {
  description = "Principal (object) IDs granted AcrPull - typically the managed identity."
  type        = list(string)
  default     = []
}
