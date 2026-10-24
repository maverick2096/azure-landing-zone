output "namespace_id" {
  description = "Resource ID of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.ns.id
}

output "namespace_name" {
  description = "Name of the Service Bus namespace."
  value       = azurerm_servicebus_namespace.ns.name
}

output "endpoint" {
  description = "The Service Bus endpoint URL."
  value       = azurerm_servicebus_namespace.ns.endpoint
}

output "private_endpoint_id" {
  description = "Resource ID of the namespace private endpoint."
  value       = azurerm_private_endpoint.sb.id
}
