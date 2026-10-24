output "id" {
  description = "Resource ID of the App Service Plan."
  value       = azurerm_service_plan.plan.id
}

output "name" {
  description = "Name of the App Service Plan."
  value       = azurerm_service_plan.plan.name
}

output "os_type" {
  description = "OS type of the plan."
  value       = azurerm_service_plan.plan.os_type
}
