output "id" {
  description = "Resource ID of the function app."
  value       = azurerm_linux_function_app.fn.id
}

output "name" {
  description = "Name of the function app."
  value       = azurerm_linux_function_app.fn.name
}

output "default_hostname" {
  description = "Default hostname of the function app."
  value       = azurerm_linux_function_app.fn.default_hostname
}

output "service_plan_id" {
  description = "Resource ID of the dedicated plan created for this function app."
  value       = azurerm_service_plan.plan.id
}

output "identity_principal_id" {
  description = "Principal ID of the function app's system-assigned identity."
  value       = azurerm_linux_function_app.fn.identity[0].principal_id
}

output "private_endpoint_id" {
  description = "Resource ID of the function app private endpoint."
  value       = azurerm_private_endpoint.fn.id
}
