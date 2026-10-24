variable "app_insights_name" {
  description = "Name of the Application Insights component."
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

variable "application_type" {
  description = "Application Insights application type."
  type        = string
  default     = "web"
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace backing this component (workspace-based App Insights)."
  type        = string
}

variable "ampls_name" {
  description = "Name of the Azure Monitor Private Link Scope to attach this component to (from the log_analytics module)."
  type        = string
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
