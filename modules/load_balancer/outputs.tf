output "lb_id" {
  description = "Load balancer resource id"
  value       = azurerm_lb.this.id
}

output "frontend_ip_id" {
  description = "LB frontend IP configuration id"
  value       = azurerm_lb.this.frontend_ip_configuration[0].id
}

output "frontend_ip_configuration_ids" {
  description = "LB frontend IP configuration ids (for compatibility)"
  value       = [azurerm_lb.this.frontend_ip_configuration[0].id]
}

output "backend_pool_id" {
  description = "LB backend pool id"
  value       = azurerm_lb_backend_address_pool.this.id
}

output "frontend_ip_address" {
  description = "Frontend private IP address"
  value       = azurerm_lb.this.frontend_ip_configuration[0].private_ip_address
}

output "nat_rule_id" {
  description = "NAT rule ID"
  value       = azurerm_lb_nat_rule.nat_rule.id
}

output "nat_pool_id" {
  description = "NAT pool ID"
  value       = length(azurerm_lb_nat_pool.nat_pool) > 0 ? azurerm_lb_nat_pool.nat_pool[0].id : null
}

output "probe_id" {
  description = "Load balancer health probe ID"
  value       = azurerm_lb_probe.health_probe.id
}
