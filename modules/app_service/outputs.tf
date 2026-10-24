output "id" {
  description = "Resource ID of the web app."
  value       = azurerm_linux_web_app.app.id
}

output "name" {
  description = "Name of the web app."
  value       = azurerm_linux_web_app.app.name
}

output "default_hostname" {
  description = "Default hostname of the web app."
  value       = azurerm_linux_web_app.app.default_hostname
}

output "service_plan_id" {
  description = "Resource ID of the dedicated plan created for this app."
  value       = azurerm_service_plan.plan.id
}

output "identity_principal_id" {
  description = "Principal ID of the app's system-assigned identity."
  value       = azurerm_linux_web_app.app.identity[0].principal_id
}

output "private_endpoint_id" {
  description = "Resource ID of the app private endpoint."
  value       = azurerm_private_endpoint.app.id
}
