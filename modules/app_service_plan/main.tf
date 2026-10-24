############################################
# App Service Plan
############################################
# A service plan has no private endpoint; the apps running on it are made
# private (VNet integration + private endpoints) in their own modules. This
# module manages the plan, its diagnostics and optional autoscale.
############################################

resource "azurerm_service_plan" "plan" {
  name                = var.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

############################################
# Diagnostic settings
############################################
resource "azurerm_monitor_diagnostic_setting" "plan" {
  name                       = "diag-${var.plan_name}"
  target_resource_id         = azurerm_service_plan.plan.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

############################################
# Optional autoscale
############################################
resource "azurerm_monitor_autoscale_setting" "plan" {
  count               = var.enable_autoscale ? 1 : 0
  name                = "as-${var.plan_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = azurerm_service_plan.plan.id
  tags                = var.tags

  profile {
    name = "default-autoscale"

    capacity {
      minimum = tostring(var.autoscale_min_capacity)
      maximum = tostring(var.autoscale_max_capacity)
      default = tostring(var.autoscale_default_capacity)
    }

    rule {
      metric_trigger {
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.autoscale_cpu_scale_out_threshold
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
        metric_name        = "CpuPercentage"
        metric_resource_id = azurerm_service_plan.plan.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.autoscale_cpu_scale_in_threshold
      }
      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
