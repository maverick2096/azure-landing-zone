output "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace (pass to other modules' log_analytics_workspace_id)."
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "ampls_id" {
  description = "Resource ID of the Azure Monitor Private Link Scope."
  value       = azurerm_monitor_private_link_scope.this.id
}

output "ampls_name" {
  description = "Name of the Azure Monitor Private Link Scope (pass to the app_insights module to attach it)."
  value       = azurerm_monitor_private_link_scope.this.name
}

output "monitor_private_dns_zone_ids" {
  description = "Map of the monitor private DNS zone IDs created by this module."
  value       = { for k, z in azurerm_private_dns_zone.monitor : k => z.id }
}
