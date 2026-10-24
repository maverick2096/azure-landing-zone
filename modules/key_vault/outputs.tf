output "id" {
  description = "Resource ID of the Key Vault."
  value       = azurerm_key_vault.kv.id
}

output "name" {
  description = "Name of the Key Vault."
  value       = azurerm_key_vault.kv.name
}

output "vault_uri" {
  description = "URI of the Key Vault."
  value       = azurerm_key_vault.kv.vault_uri
}

output "private_endpoint_id" {
  description = "Resource ID of the Key Vault private endpoint."
  value       = azurerm_private_endpoint.kv.id
}
