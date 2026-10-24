output "storage_account_id" {
  description = "Resource ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary access key (only populated when shared_access_key_enabled = true)."
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "private_endpoint_id" {
  description = "Resource ID of the blob private endpoint."
  value       = azurerm_private_endpoint.blob.id
}
