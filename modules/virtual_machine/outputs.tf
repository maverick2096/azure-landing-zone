output "id" {
  description = "Resource ID of the virtual machine."
  value       = local.vm_id
}

output "name" {
  description = "Name of the virtual machine."
  value       = var.vm_name
}

output "private_ip_address" {
  description = "Private IP address of the VM NIC."
  value       = azurerm_network_interface.this.private_ip_address
}

output "nic_id" {
  description = "Resource ID of the network interface."
  value       = azurerm_network_interface.this.id
}

output "identity_principal_id" {
  description = "Principal ID of the VM's system-assigned identity (null if not enabled)."
  value = local.is_windows ? (
    try(azurerm_windows_virtual_machine.this[0].identity[0].principal_id, null)
    ) : (
    try(azurerm_linux_virtual_machine.this[0].identity[0].principal_id, null)
  )
}
