variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "sku" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "log_analytics_name" {
  type = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID where Recovery Services Vault private endpoint will be deployed"
  type        = string
  default     = null
}

variable "virtual_network_id" {
  description = "Existing virtual network to associate private DNS links with"
  type        = string
  default     = null
}

# Backup Policy Variables
variable "default_backup_time" {
  type        = string
  description = "Default backup schedule time (HH:MM format)"
  default     = "23:00"
}

variable "default_retention_daily_count" {
  type        = number
  description = "Default daily retention count"
  default     = 30
}

variable "default_retention_weekly_count" {
  type        = number
  description = "Default weekly retention count"
  default     = 12
}

variable "default_retention_weekly_days" {
  type        = list(string)
  description = "Default weekly backup days"
  default     = ["Sunday"]
}

variable "default_retention_monthly_count" {
  type        = number
  description = "Default monthly retention count"
  default     = 12
}

variable "default_retention_monthly_weeks" {
  type        = list(string)
  description = "Default monthly backup weeks"
  default     = ["First", "Last"]
}

variable "default_retention_yearly_count" {
  type        = number
  description = "Default yearly retention count"
  default     = 3
}

variable "default_retention_yearly_months" {
  type        = list(string)
  description = "Default yearly backup months"
  default     = ["January", "June", "December"]
}

variable "timezone" {
  type        = string
  description = "Timezone for backup schedules"
  default     = "UTC"
}