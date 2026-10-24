output "zone_ids" {
  description = "Map of zone name => private DNS zone resource ID."
  value       = { for k, z in azurerm_private_dns_zone.this : k => z.id }
}

output "zone_names" {
  description = "List of created zone names."
  value       = [for z in azurerm_private_dns_zone.this : z.name]
}
