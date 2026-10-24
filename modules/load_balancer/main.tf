resource "azurerm_lb" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.lb_sku
  tags                = var.tags

  frontend_ip_configuration {
    name                          = var.frontend_ip_configuration_name
    subnet_id                     = var.subnet_id
    private_ip_address            = var.private_ip_address
    private_ip_address_allocation = var.private_ip_address != null && var.private_ip_address != "" ? "Static" : "Dynamic"
    zones                         = length(var.zones) > 0 ? var.zones : null
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  name            = var.backend_pool_name
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_network_interface_backend_address_pool_association" "this" {
  count = length(var.backend_pool_network_interface_ids)

  network_interface_id    = var.backend_pool_network_interface_ids[count.index]
  ip_configuration_name   = var.backend_pool_ip_configuration_name
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id
}

locals {
  backend_pool_address_map = {
    for item in var.backend_pool_addresses :
    trimspace(item.name) != "" ? trimspace(item.name) : replace(item.ip_address, ".", "-") => {
      name               = trimspace(item.name) != "" ? trimspace(item.name) : replace(item.ip_address, ".", "-")
      ip_address         = item.ip_address
      virtual_network_id = item.virtual_network_id
    }
  }
}

resource "azurerm_lb_backend_address_pool_address" "this" {
  for_each                = local.backend_pool_address_map
  name                    = each.value.name
  backend_address_pool_id = azurerm_lb_backend_address_pool.this.id
  virtual_network_id      = each.value.virtual_network_id
  ip_address              = each.value.ip_address
}

resource "azurerm_lb_probe" "health_probe" {
  name                = var.probe_name
  loadbalancer_id     = azurerm_lb.this.id
  protocol            = var.probe_protocol
  port                = var.probe_port
  request_path        = var.probe_protocol == "Http" || var.probe_protocol == "Https" ? var.probe_path : null
  interval_in_seconds = var.probe_interval_in_seconds
  number_of_probes    = var.probe_number_of_probes
}

resource "azurerm_lb_rule" "lb_rule" {
  name                           = var.lb_rule_name
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = var.lb_rule_protocol
  frontend_port                  = var.lb_rule_port
  backend_port                   = var.lb_rule_port
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this.id]
  probe_id                       = azurerm_lb_probe.health_probe.id
  idle_timeout_in_minutes        = var.lb_rule_idle_timeout_in_minutes
  enable_floating_ip             = var.enable_floating_ip
  enable_tcp_reset               = var.enable_tcp_reset
}

resource "azurerm_lb_nat_rule" "nat_rule" {
  name                           = var.nat_rule_name
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = var.nat_rule_protocol
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  idle_timeout_in_minutes        = var.nat_rule_idle_timeout_in_minutes
  enable_floating_ip             = var.nat_rule_enable_floating_ip
  enable_tcp_reset               = var.nat_rule_enable_tcp_reset
  backend_port                   = var.nat_rule_backend_port

  frontend_port           = var.use_nat_rule_v2 ? null : var.nat_rule_frontend_port
  backend_address_pool_id = var.use_nat_rule_v2 ? azurerm_lb_backend_address_pool.this.id : null
  frontend_port_start     = var.use_nat_rule_v2 ? var.nat_rule_frontend_port : null
  frontend_port_end       = var.use_nat_rule_v2 ? (var.nat_rule_frontend_port_end != null ? var.nat_rule_frontend_port_end : var.nat_rule_frontend_port) : null
}

resource "azurerm_lb_nat_pool" "nat_pool" {
  count                          = var.nat_pool_name != null && var.nat_pool_name != "" ? 1 : 0
  loadbalancer_id                = azurerm_lb.this.id
  resource_group_name            = var.resource_group_name
  name                           = var.nat_pool_name
  protocol                       = var.nat_pool_protocol
  frontend_port_start            = var.nat_pool_frontend_port_start
  frontend_port_end              = var.nat_pool_frontend_port_end
  backend_port                   = var.nat_pool_backend_port
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
}

resource "azurerm_monitor_diagnostic_setting" "lb_diagnostics" {
  count                          = var.enable_diagnostics && (var.log_analytics_workspace_id != null || var.diagnostics_storage_account_id != null || var.eventhub_authorization_rule_id != null) ? 1 : 0
  name                           = "diag-${var.name}"
  target_resource_id             = azurerm_lb.this.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.diagnostics_storage_account_id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name                  = var.eventhub_name

  enabled_log {
    category_group = "allLogs"
  }

  #enabled_metric {
  #  category = "AllMetrics"
  #}
  enabled_metric {
    category = "AllMetrics"
  }

}
/*
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
      name      = "internal"
      primary   = true
      subnet_id = var.vmss_rpt_subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.this.id]
    }
  }
  
  automatic_instance_repair {
    grace_period = "PT30M"
    enabled = var.vmss_rpt_automatic_instance_repair
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
  count               = var.enable_vmss_drools ? 1 : 0
  name                = var.vmss_drools_name
  computer_name_prefix = var.vmss_drools_computer_name_prefix
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vmss_drools_vm_size
  instances           = var.vmss_drools_instance_count
  admin_username      = var.vmss_drools_admin_username
  
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
      name      = "internal"
      primary   = true
      subnet_id = var.vmss_drools_subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.this.id]
    }
  }
  
  automatic_instance_repair {
    grace_period = "PT30M" 
    enabled = var.vmss_drools_automatic_instance_repair
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
}*/