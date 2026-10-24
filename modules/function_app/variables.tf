variable "function_app_name" {
  description = "Name of the Linux Function App."
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
  description = "Name of the dedicated App Service Plan this function app creates."
  type        = string
}

variable "plan_sku_name" {
  description = "SKU of the dedicated plan (e.g. P1v3)."
  type        = string
  default     = "P1v3"
}

# ---------- Backing storage (required by Functions) ----------
variable "storage_account_name" {
  description = "Name of the storage account backing the function app (from the storage_account module)."
  type        = string
}

variable "storage_account_access_key" {
  description = "Access key for the backing storage account."
  type        = string
  sensitive   = true
}

# ---------- Runtime stack (set one; leave others null) ----------
variable "node_version" {
  description = "Node.js version (e.g. 20). Null if not Node."
  type        = string
  default     = null
}

variable "python_version" {
  description = "Python version (e.g. 3.11). Null if not Python."
  type        = string
  default     = null
}

variable "dotnet_version" {
  description = ".NET version (e.g. 8.0). Null if not .NET."
  type        = string
  default     = null
}

variable "java_version" {
  description = "Java version (e.g. 17). Null if not Java."
  type        = string
  default     = null
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

variable "application_insights_connection_string" {
  description = "Application Insights connection string for the function app. Null to skip."
  type        = string
  default     = null
  sensitive   = true
}

variable "user_assigned_identity_ids" {
  description = "User-assigned managed identity IDs to attach (e.g. the platform managed identity)."
  type        = list(string)
  default     = []
}

# ---------- Networking ----------
variable "private_endpoint_subnet_id" {
  description = "Subnet ID where the function app private endpoint is created."
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
