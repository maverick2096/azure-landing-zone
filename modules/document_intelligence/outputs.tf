output "id" {
  description = "Resource ID of the Document Intelligence account."
  value       = azurerm_cognitive_account.this.id
}

output "name" {
  description = "Name of the account."
  value       = azurerm_cognitive_account.this.name
}

output "endpoint" {
  description = "The Document Intelligence endpoint URL."
  value       = azurerm_cognitive_account.this.endpoint
}

output "primary_access_key" {
  description = "Primary API key (populated only when local_auth_enabled = true)."
  value       = azurerm_cognitive_account.this.primary_access_key
  sensitive   = true
}

output "identity_principal_id" {
  description = "Principal ID of the account's system-assigned identity."
  value       = azurerm_cognitive_account.this.identity[0].principal_id
}

output "private_endpoint_id" {
  description = "Resource ID of the private endpoint."
  value       = azurerm_private_endpoint.di.id
}
