variable "name" {
  description = "The name of the Network Security Group"
  type        = string
}

variable "location" {
  description = "Azure region for the NSG"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name where NSG will be created"
  type        = string
}

variable "security_rules" {
  description = "List of NSG rules. Each rule can have individual port ranges, address prefixes, etc."
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
    description                  = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags map to apply to NSG"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "Subnet ID for association (if associate_to_subnet = true)"
  type        = string
  default     = null
}

variable "associate_to_subnet" {
  description = "Whether to associate NSG to subnet"
  type        = bool
  default     = true
}

variable "nic_id" {
  description = "NIC ID for association (if associate_to_nic = true)"
  type        = string
  default     = null
}

variable "associate_to_nic" {
  description = "Whether to associate NSG to a NIC"
  type        = bool
  default     = false
}

variable "prevent_destroy" {
  description = "Prevent destruction of the NSG"
  type        = bool
  default     = false
}

variable "ignore_tags_changes" {
  description = "Ignore changes to tags"
  type        = bool
  default     = false
}

variable "lifecycle_create_before_destroy" {
  description = "Create new resource before destroying old one (helps with apply failures)"
  type        = bool
  default     = true
}
variable "log_analytics_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string

}

# Azure Monitor Diagnostic Settings - Added for NSG diagnostics
variable "enable_diagnostics" {
  description = "Enable Azure Monitor diagnostic settings for NSG"
  type        = bool
  default     = false
}
variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings (full resource ID). Alternative to log_analytics_name."
  type        = string
  default     = null
}
variable "diagnostics_storage_account_id" {
  description = "Storage account ID for diagnostic settings (full resource ID). Alternative to Log Analytics."
  type        = string
  default     = null
}
variable "eventhub_authorization_rule_id" {
  description = "Event Hub authorization rule ID for diagnostic settings"
  type        = string
  default     = null
}
variable "eventhub_name" {
  description = "Event Hub name for diagnostic settings"
  type        = string
  default     = null
}

# Virtual Network Flow Logs Configuration - Added 23/11
variable "flow_log_storage_account_id" {
  description = "Storage account ID where VNet flow logs will be stored"
  type        = string
  default     = null
}
variable "flow_log_network_watcher_name" {
  description = "Name of the Network Watcher (if using existing). If not provided, will use default NetworkWatcher_<region>"
  type        = string
  default     = null
}
variable "flow_log_network_watcher_resource_group_name" {
  description = "Resource group name where Network Watcher is located (defaults to NetworkWatcherRG)"
  type        = string
  default     = "NetworkWatcherRG"
}
variable "flow_log_retention_days" {
  description = "Number of days to retain flow logs in storage account"
  type        = number
  default     = 7
}
variable "flow_log_enable_traffic_analytics" {
  description = "Enable Traffic Analytics for VNet Flow Logs (requires Log Analytics workspace)"
  type        = bool
  default     = false
}
variable "flow_log_traffic_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID for Traffic Analytics"
  type        = string
  default     = null
}
variable "flow_log_traffic_analytics_workspace_region" {
  description = "Region of the Log Analytics workspace for Traffic Analytics"
  type        = string
  default     = null
}
variable "flow_log_traffic_analytics_interval" {
  description = "How frequently Traffic Analytics should query flow logs (in minutes). Valid values: 10 or 60"
  type        = number
  default     = 60
  validation {
    condition     = var.flow_log_traffic_analytics_interval == null || contains([10, 60], var.flow_log_traffic_analytics_interval)
    error_message = "flow_log_traffic_analytics_interval must be 10 or 60 minutes."
  }
}