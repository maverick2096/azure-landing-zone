variable "app_name" {
  description = "Name of the Linux Web App."
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

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

# ---------- Dedicated plan (created by this module) ----------
variable "plan_name" {
  description = "Name of the dedicated App Service Plan this app creates."
  type        = string
}

variable "plan_sku_name" {
  description = "SKU of the dedicated plan (e.g. P1v3)."
  type        = string
  default     = "P1v3"
}

# ---------- App configuration ----------
variable "app_settings" {
  description = "App settings (key/value)."
  type        = map(string)
  default     = {}
}

variable "minimum_tls_version" {
  description = "Minimum TLS version."
  type        = string
  default     = "1.2"
}

variable "health_check_path" {
  description = "Health check path."
  type        = string
  default     = "/"
}

variable "user_assigned_identity_ids" {
  description = "User-assigned managed identity IDs to attach (e.g. the platform managed identity)."
  type        = list(string)
  default     = []
}

# ---------- Optional container image (from ACR) ----------
variable "container_registry_url" {
  description = "Container registry URL (e.g. https://myacr.azurecr.io). Required if container_image_name is set."
  type        = string
  default     = null
}

variable "container_image_name" {
  description = "Container image name (repository). If null, no docker application stack is configured."
  type        = string
  default     = null
}

variable "container_image_tag" {
  description = "Container image tag."
  type        = string
  default     = "latest"
}

# ---------- Networking ----------
variable "private_endpoint_subnet_id" {
  description = "Subnet ID where the app private endpoint is created."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "IDs of the EXISTING private DNS zone(s) for App Service (privatelink.azurewebsites.net)."
  type        = list(string)
}

variable "vnet_integration_subnet_id" {
  description = "Delegated subnet ID for regional VNet integration (outbound). Null to disable."
  type        = string
  default     = null
}

# ---------- Diagnostics ----------
variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for diagnostic settings."
  type        = string
}
