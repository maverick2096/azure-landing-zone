############################################
# Application Insights (workspace-based, private)
############################################
resource "azurerm_application_insights" "this" {
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type
  workspace_id        = var.log_analytics_workspace_id

  # No public ingestion / query - telemetry flows through the AMPLS.
  internet_ingestion_enabled = false
  internet_query_enabled     = false

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
      workspace_id,
    ]
  }
}

############################################
# Attach App Insights to the Azure Monitor Private Link Scope
############################################
resource "azurerm_monitor_private_link_scoped_service" "appinsights" {
  name                = "amplss-${var.app_insights_name}"
  resource_group_name = var.resource_group_name
  scope_name          = var.ampls_name
  linked_resource_id  = azurerm_application_insights.this.id
}
