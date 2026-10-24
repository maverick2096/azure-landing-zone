variable "plan_name" {
  description = "Name of the App Service Plan."
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

variable "os_type" {
  description = "OS type for the plan (Linux or Windows)."
  type        = string
  default     = "Linux"
}

variable "sku_name" {
  description = "Plan SKU (e.g. P1v3, S1)."
  type        = string
  default     = "P1v3"
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace for diagnostic settings."
  type        = string
}

# ---------- Autoscale ----------
variable "enable_autoscale" {
  description = "Create an autoscale setting for the plan."
  type        = bool
  default     = false
}

variable "autoscale_min_capacity" {
  description = "Minimum instance count."
  type        = number
  default     = 1
}

variable "autoscale_max_capacity" {
  description = "Maximum instance count."
  type        = number
  default     = 5
}

variable "autoscale_default_capacity" {
  description = "Default instance count."
  type        = number
  default     = 1
}

variable "autoscale_cpu_scale_out_threshold" {
  description = "CPU percent that triggers scale-out."
  type        = number
  default     = 60
}

variable "autoscale_cpu_scale_in_threshold" {
  description = "CPU percent that triggers scale-in."
  type        = number
  default     = 30
}
