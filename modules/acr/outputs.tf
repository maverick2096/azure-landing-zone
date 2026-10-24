output "id" {
  description = "Resource ID of the container registry."
  value       = azurerm_container_registry.acr.id
}

output "name" {
  description = "Name of the container registry."
  value       = azurerm_container_registry.acr.name
}

output "login_server" {
  description = "Login server (e.g. myacr.azurecr.io)."
  value       = azurerm_container_registry.acr.login_server
}

output "identity_principal_id" {
  description = "Principal ID of the registry's system-assigned identity."
  value       = azurerm_container_registry.acr.identity[0].principal_id
}

output "private_endpoint_id" {
  description = "Resource ID of the registry private endpoint."
  value       = azurerm_private_endpoint.acr.id
}
