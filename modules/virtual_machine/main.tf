############################################
# Standalone Virtual Machine (Windows or Linux)
############################################
# Private-only: the NIC has no public IP. Telemetry flows to Log Analytics via
# the Azure Monitor Agent (optionally associated with a Data Collection Rule).
############################################

locals {
  is_windows = var.os_type == "Windows"
  is_linux   = var.os_type == "Linux"

  use_ssh_key = local.is_linux && var.ssh_public_key != "" && var.ssh_public_key != null

  # Windows computer names are limited to 15 chars.
  computer_name = var.computer_name != "" ? var.computer_name : (
    local.is_windows ? substr(replace(var.vm_name, "-", ""), 0, 15) : var.vm_name
  )

  identity_type = (
    var.enable_system_assigned_identity && length(var.user_assigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" :
    var.enable_system_assigned_identity ? "SystemAssigned" :
    length(var.user_assigned_identity_ids) > 0 ? "UserAssigned" : null
  )

  vm_id = local.is_windows ? azurerm_windows_virtual_machine.this[0].id : azurerm_linux_virtual_machine.this[0].id

  # Azure Monitor Agent extension differs by OS.
  ama_type = local.is_windows ? "AzureMonitorWindowsAgent" : "AzureMonitorLinuxAgent"
}

############################################
# Network interface (no public IP)
############################################
resource "azurerm_network_interface" "this" {
  name                = coalesce(var.nic_name, "nic-${var.vm_name}")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = var.ip_configuration_name
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_allocation
    private_ip_address            = var.private_ip_allocation == "Static" ? var.private_ip : null
    # No public_ip_address_id - this NIC is private only.
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

############################################
# Windows VM
############################################
resource "azurerm_windows_virtual_machine" "this" {
  count = local.is_windows ? 1 : 0

  name                  = var.vm_name
  computer_name         = local.computer_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.this.id]
  availability_set_id   = var.availability_set_id
  zone                  = var.zone
  patch_mode            = var.patch_mode
  provision_vm_agent    = true
  tags                  = var.tags

  os_disk {
    name                 = var.os_disk_name
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  dynamic "identity" {
    for_each = local.identity_type == null ? [] : [1]
    content {
      type         = local.identity_type
      identity_ids = var.user_assigned_identity_ids
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

############################################
# Linux VM
############################################
resource "azurerm_linux_virtual_machine" "this" {
  count = local.is_linux ? 1 : 0

  name                            = var.vm_name
  computer_name                   = local.computer_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = local.use_ssh_key ? null : var.admin_password
  disable_password_authentication = local.use_ssh_key
  network_interface_ids           = [azurerm_network_interface.this.id]
  availability_set_id             = var.availability_set_id
  zone                            = var.zone
  provision_vm_agent              = true
  tags                            = var.tags

  dynamic "admin_ssh_key" {
    for_each = local.use_ssh_key ? [1] : []
    content {
      username   = var.admin_username
      public_key = var.ssh_public_key
    }
  }

  os_disk {
    name                 = var.os_disk_name
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  dynamic "identity" {
    for_each = local.identity_type == null ? [] : [1]
    content {
      type         = local.identity_type
      identity_ids = var.user_assigned_identity_ids
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.enable_boot_diagnostics ? [1] : []
    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

############################################
# Monitoring - Azure Monitor Agent + optional DCR association
############################################
resource "azurerm_virtual_machine_extension" "ama" {
  count = var.enable_monitoring ? 1 : 0

  name                       = local.ama_type
  virtual_machine_id         = local.vm_id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = local.ama_type
  type_handler_version       = local.is_windows ? "1.0" : "1.0"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = var.automatic_extension_upgrade_enabled
  tags                       = var.tags
}

resource "azurerm_monitor_data_collection_rule_association" "this" {
  count = var.data_collection_rule_id != null ? 1 : 0

  name                    = "dcra-${var.vm_name}"
  target_resource_id      = local.vm_id
  data_collection_rule_id = var.data_collection_rule_id

  depends_on = [azurerm_virtual_machine_extension.ama]
}
