output "id" {
  description = "The resource ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.this.id
}

output "principal_id" {
  description = "The principal (object) ID of the managed identity - use for RBAC role assignments and Key Vault access policies."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "client_id" {
  description = "The client ID of the managed identity - use in app settings (e.g. AZURE_CLIENT_ID)."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "tenant_id" {
  description = "The tenant ID of the managed identity."
  value       = azurerm_user_assigned_identity.this.tenant_id
}
