variable "name" {
  description = "Name of the Service Bus namespace."
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
  description = "Service Bus SKU. Must be Premium for private endpoints."
  type        = string
  default     = "Premium"

  validation {
    condition     = var.sku == "Premium"
    error_message = "A private endpoint requires the Premium SKU."
  }
}

variable "capacity" {
  description = "Messaging units for Premium (1, 2, 4, 8, 16)."
  type        = number
  default     = 1
}

variable "premium_messaging_partitions" {
  description = "Number of messaging partitions for Premium."
  type        = number
  default     = 1
}

variable "topics" {
  description = "Topics to create."
  type        = list(string)
  default     = []
}

variable "queues" {
  description = "Queues to create."
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
  description = "Subnet ID where the namespace private endpoint is created."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "IDs of the EXISTING private DNS zone(s) for Service Bus (privatelink.servicebus.windows.net)."
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
  description = "Built-in role to grant role_principal_ids on the namespace."
  type        = string
  default     = "Azure Service Bus Data Owner"
}
