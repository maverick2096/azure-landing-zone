
############################
# Virtual Machine Scale Sets
############################

# Windows VMSS (Rpt)
resource "azurerm_windows_virtual_machine_scale_set" "rpt" {
  count                = var.enable_vmss_rpt ? 1 : 0
  name                 = var.vmss_rpt_name
  computer_name_prefix = var.vmss_rpt_computer_name_prefix
  resource_group_name  = var.resource_group_name
  location             = var.location
  sku                  = var.vmss_rpt_vm_size
  instances            = var.vmss_rpt_instance_count
  admin_username       = var.vmss_rpt_admin_username
  admin_password       = var.vmss_rpt_admin_password
  license_type         = var.vmss_rpt_license_type
  timezone             = var.vmss_rpt_timezone

  source_image_reference {
    publisher = var.vmss_rpt_image_publisher
    offer     = var.vmss_rpt_image_offer
    sku       = var.vmss_rpt_image_sku
    version   = var.vmss_rpt_image_version
  }

  os_disk {
    caching                   = var.vmss_rpt_os_disk_caching
    storage_account_type      = var.vmss_rpt_os_disk_storage_account_type
    disk_size_gb              = var.vmss_rpt_os_disk_size_gb
    write_accelerator_enabled = var.vmss_rpt_os_disk_write_accelerator_enabled
  }

  network_interface {
    name                          = var.vmss_rpt_nic_name
    primary                       = true
    enable_accelerated_networking = var.vmss_rpt_accelerated_networking

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.vmss_rpt_subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.this.id]
    }
  }

  automatic_instance_repair {
    grace_period = "PT30M"
    enabled      = var.vmss_rpt_automatic_instance_repair
  }

  health_probe_id = azurerm_lb_probe.health_probe.id

  identity {
    type = var.vmss_rpt_identity_type
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account_uri
  }

  tags = var.tags
}

# Linux VMSS (Drools)
resource "azurerm_linux_virtual_machine_scale_set" "drools" {
  count                = var.enable_vmss_drools ? 1 : 0
  name                 = var.vmss_drools_name
  computer_name_prefix = var.vmss_drools_computer_name_prefix
  resource_group_name  = var.resource_group_name
  location             = var.location
  sku                  = var.vmss_drools_vm_size
  instances            = var.vmss_drools_instance_count
  admin_username       = var.vmss_drools_admin_username

  admin_ssh_key {
    username   = var.vmss_drools_admin_username
    public_key = var.vmss_drools_ssh_public_key
  }

  source_image_reference {
    publisher = var.vmss_drools_image_publisher
    offer     = var.vmss_drools_image_offer
    sku       = var.vmss_drools_image_sku
    version   = var.vmss_drools_image_version
  }

  os_disk {
    caching              = var.vmss_drools_os_disk_caching
    storage_account_type = var.vmss_drools_os_disk_storage_account_type
    disk_size_gb         = var.vmss_drools_os_disk_size_gb
  }

  network_interface {
    name    = var.vmss_drools_nic_name
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.vmss_drools_subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.this.id]
    }
  }

  automatic_instance_repair {
    grace_period = "PT30M"
    enabled      = var.vmss_drools_automatic_instance_repair
  }

  health_probe_id = azurerm_lb_probe.health_probe.id

  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account_uri
  }

  tags = var.tags
}
############################
# Auto-Scaling Settings
############################

# Auto-Scaling for Windows VMSS (Rpt)
resource "azurerm_monitor_autoscale_setting" "rpt" {
  count               = var.enable_vmss_rpt && var.enable_vmss_rpt_autoscale ? 1 : 0
  name                = "autoscale-${var.vmss_rpt_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_windows_virtual_machine_scale_set.rpt[0].id

  profile {
    name = "default"

    capacity {
      default = var.vmss_rpt_instance_count
      minimum = var.vmss_rpt_min_instance_count
      maximum = var.vmss_rpt_max_instance_count
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.rpt[0].id
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.vmss_rpt_autoscale_cpu_threshold_out
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_windows_virtual_machine_scale_set.rpt[0].id
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.vmss_rpt_autoscale_cpu_threshold_in
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }
}

# Auto-Scaling for Linux VMSS (Drools)
resource "azurerm_monitor_autoscale_setting" "drools" {
  count               = var.enable_vmss_drools && var.enable_vmss_drools_autoscale ? 1 : 0
  name                = "autoscale-${var.vmss_drools_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.drools[0].id

  profile {
    name = "default"

    capacity {
      default = var.vmss_drools_instance_count
      minimum = var.vmss_drools_min_instance_count
      maximum = var.vmss_drools_max_instance_count
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.drools[0].id
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.vmss_drools_autoscale_cpu_threshold_out
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.drools[0].id
        metric_namespace   = "Microsoft.Compute/virtualMachineScaleSets"
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT10M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.vmss_drools_autoscale_cpu_threshold_in
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT10M"
      }
    }
  }
}
############################
# DNS Configuration
############################

# Private DNS Zone A Record for Drools VMSS
resource "azurerm_private_dns_a_record" "drools_vmss_dns" {
  count = var.enable_vmss_drools && var.vmss_drools_private_dns_zone_id != null ? 1 : 0

  name                = lower(var.vmss_drools_dns_record_name)
  zone_name           = split("/", var.vmss_drools_private_dns_zone_id)[8]
  resource_group_name = split("/", var.vmss_drools_private_dns_zone_id)[4]
  ttl                 = var.vmss_drools_dns_record_ttl
  records             = [azurerm_lb.this.private_ip_address]
  tags                = var.tags
}

# Private DNS Zone A Record for Rpt VMSS
resource "azurerm_private_dns_a_record" "rpt_vmss_dns" {
  count = var.enable_vmss_rpt && var.vmss_rpt_private_dns_zone_id != null ? 1 : 0

  name                = lower(var.vmss_rpt_dns_record_name)
  zone_name           = split("/", var.vmss_rpt_private_dns_zone_id)[8]
  resource_group_name = split("/", var.vmss_rpt_private_dns_zone_id)[4]
  ttl                 = var.vmss_rpt_dns_record_ttl
  records             = [azurerm_lb.this.private_ip_address]
  tags                = var.tags
}