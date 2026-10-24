data "azurerm_client_config" "current" {}


data "azurerm_linux_web_app" "webapp" {
  name                = var.webapp_name
  resource_group_name = var.resource_group_name
}

#API Data Source
data "azurerm_linux_web_app" "api" {
  name                = var.api_name
  resource_group_name = var.resource_group_name
}

#n8n data source
data "azurerm_linux_web_app" "n8n" {
  name                = var.n8n_name
  resource_group_name = var.resource_group_name
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

/*data "azurerm_api_management" "apim" {
  name                = var.apim_name
  resource_group_name = var.resource_group_name
}
*/
data "azurerm_storage_account" "storage" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault" "kv" {
  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_postgresql_flexible_server" "postgres" {
  name                = var.postgresql_server_name
  resource_group_name = var.resource_group_name
}

data "azurerm_servicebus_namespace" "sb" {
  name                = var.servicebus_namespace_name
  resource_group_name = var.resource_group_name
}

# Container Registry Role Assignment
resource "azurerm_role_assignment" "webapp_to_acr" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_linux_web_app.webapp.identity[0].principal_id
}

/*
# API Management Role Assignment
resource "azurerm_role_assignment" "webapp_to_apim" {
  scope                = data.azurerm_api_management.apim.id
  #role_definition_name = "API Management Service Reader"
  role_definition_name = "Reader"
  principal_id         = data.azurerm_linux_web_app.webapp.identity[0].principal_id
}
*/
# Storage Blob Contributor Role Assignment
resource "azurerm_role_assignment" "webapp_to_storage" {
  scope                = data.azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_linux_web_app.webapp.identity[0].principal_id
}

# Key Vault Secrets User
resource "azurerm_role_assignment" "webapp_to_keyvault" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_linux_web_app.webapp.identity[0].principal_id
}

# PostgreSQL Role Assignment
resource "azurerm_role_assignment" "webapp_to_postgres" {
  scope                = data.azurerm_postgresql_flexible_server.postgres.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_linux_web_app.webapp.identity[0].principal_id
}
/*
# Service Bus Sender Role Assignment
resource "azurerm_role_assignment" "webapp_to_servicebus_sender" {
  scope                = data.azurerm_servicebus_namespace.sb.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = data.azurerm_linux_web_app.webapp.identity[0].principal_id
}
# Service Bus Receiver Role Assignment
resource "azurerm_role_assignment" "webapp_to_servicebus_receiver" {
  scope                = data.azurerm_servicebus_namespace.sb.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = data.azurerm_linux_web_app.webapp.identity[0].principal_id
}
/
*/

# Service Bus Role Assignment
resource "azurerm_role_assignment" "webapp_to_servicebus" {
  scope                = data.azurerm_servicebus_namespace.sb.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = data.azurerm_linux_web_app.webapp.identity[0].principal_id
}

# ==================== API RBAC ASSIGNMENTS ====================

# Container Registry Role Assignment for API
resource "azurerm_role_assignment" "api_to_acr" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_linux_web_app.api.identity[0].principal_id
}

/*
# API Management Role Assignment for API
resource "azurerm_role_assignment" "api_to_apim" {
  scope                = data.azurerm_api_management.apim.id
  #role_definition_name = "API Management Service Reader"
  role_definition_name = "Reader"
  principal_id         = data.azurerm_linux_web_app.api.identity[0].principal_id
}
*/

# Storage Blob Contributor Role Assignment for API
resource "azurerm_role_assignment" "api_to_storage" {
  scope                = data.azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_linux_web_app.api.identity[0].principal_id
}

# Key Vault Secrets User for API
resource "azurerm_role_assignment" "api_to_keyvault" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_linux_web_app.api.identity[0].principal_id
}

# PostgreSQL Role Assignment for API
resource "azurerm_role_assignment" "api_to_postgres" {
  scope                = data.azurerm_postgresql_flexible_server.postgres.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_linux_web_app.api.identity[0].principal_id
}
/*
# Service Bus Sender Role Assignment for API
resource "azurerm_role_assignment" "api_to_servicebus_sender" {
  scope                = data.azurerm_servicebus_namespace.sb.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = data.azurerm_linux_web_app.api.identity[0].principal_id
}

# Service Bus Receiver Role Assignment for API
resource "azurerm_role_assignment" "api_to_servicebus_receiver" {
  scope                = data.azurerm_servicebus_namespace.sb.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = data.azurerm_linux_web_app.api.identity[0].principal_id
}
*/

# Service Bus Role Assignment for API
resource "azurerm_role_assignment" "api_to_servicebus" {
  scope                = data.azurerm_servicebus_namespace.sb.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = data.azurerm_linux_web_app.api.identity[0].principal_id
}

# ==================== N8N RBAC ASSIGNMENTS ====================

# Container Registry Role Assignment for n8n
resource "azurerm_role_assignment" "n8n_to_acr" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_linux_web_app.n8n.identity[0].principal_id
}

/*
# API Management Role Assignment for n8n
resource "azurerm_role_assignment" "n8n_to_apim" {
  scope                = data.azurerm_api_management.apim.id
  #role_definition_name = "API Management Service Reader"
  role_definition_name = "Reader"
  principal_id         = data.azurerm_linux_web_app.n8n.identity[0].principal_id
}
*/

# Storage Blob Contributor Role Assignment for n8n
resource "azurerm_role_assignment" "n8n_to_storage" {
  scope                = data.azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_linux_web_app.n8n.identity[0].principal_id
}

# Key Vault Secrets User for n8n
resource "azurerm_role_assignment" "n8n_to_keyvault" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_linux_web_app.n8n.identity[0].principal_id
}

resource "azurerm_role_assignment" "n8n_to_postgres" {
  scope                = data.azurerm_postgresql_flexible_server.postgres.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_linux_web_app.n8n.identity[0].principal_id
}

/*
# Service Bus Sender Role Assignment for n8n
resource "azurerm_role_assignment" "n8n_to_servicebus_sender" {
  scope                = data.azurerm_servicebus_namespace.sb.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = data.azurerm_linux_web_app.n8n.identity[0].principal_id
}

# Service Bus Receiver Role Assignment for n8n
resource "azurerm_role_assignment" "n8n_to_servicebus_receiver" {
  scope                = data.azurerm_servicebus_namespace.sb.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = data.azurerm_linux_web_app.n8n.identity[0].principal_id
}
*/

# Service Bus Role Assignment for n8n
resource "azurerm_role_assignment" "n8n_to_servicebus" {
  scope                = data.azurerm_servicebus_namespace.sb.id
  role_definition_name = "Azure Service Bus Data Owner"
  principal_id         = data.azurerm_linux_web_app.n8n.identity[0].principal_id
}
/*
#VM's
data "azurerm_windows_virtual_machine" "windows_vms" {
  for_each            = toset(var.windows_vm_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

data "azurerm_linux_virtual_machine" "linux_vms" {
  for_each            = toset(var.linux_vm_names)
  name                = each.value
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "windows_vm_to_acr" {
  for_each             = data.azurerm_windows_virtual_machine.windows_vms
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = each.value.identity[0].principal_id
}

resource "azurerm_role_assignment" "linux_vm_to_acr" {
  for_each             = data.azurerm_linux_virtual_machine.linux_vms
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = each.value.identity[0].principal_id
}
*/
/*
# ==================== APIM RBAC ASSIGNMENTS ====================

# Container Registry Role Assignment for APIM
resource "azurerm_role_assignment" "apim_to_acr" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_api_management.apim.identity[0].principal_id
}

# Storage Blob Contributor Role Assignment for APIM
resource "azurerm_role_assignment" "apim_to_storage" {
  scope                = data.azurerm_storage_account.storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_api_management.apim.identity[0].principal_id
}

# Key Vault Secrets User for APIM
resource "azurerm_role_assignment" "apim_to_keyvault" {
  scope                = data.azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_api_management.apim.identity[0].principal_id
}

# PostgreSQL Role Assignment for APIM
resource "azurerm_role_assignment" "apim_to_postgres" {
  scope                = data.azurerm_postgresql_flexible_server.postgres.id
  role_definition_name = "Reader"
  principal_id         = data.azurerm_api_management.apim.identity[0].principal_id
}

# Service Bus Sender Role Assignment for APIM
resource "azurerm_role_assignment" "apim_to_servicebus_sender" {
  scope                = data.azurerm_servicebus_namespace.sb.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = data.azurerm_api_management.apim.identity[0].principal_id
}

# Service Bus Receiver Role Assignment for APIM
resource "azurerm_role_assignment" "apim_to_servicebus_receiver" {
  scope                = data.azurerm_servicebus_namespace.sb.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = data.azurerm_api_management.apim.identity[0].principal_id
}

*/

output "role_assignments" {
  description = "Map of all web app role assignments created"
  value = {
    webapp_to_acr = azurerm_role_assignment.webapp_to_acr.id
    #webapp_to_apim                = azurerm_role_assignment.webapp_to_apim.id
    webapp_to_storage    = azurerm_role_assignment.webapp_to_storage.id
    webapp_to_keyvault   = azurerm_role_assignment.webapp_to_keyvault.id
    webapp_to_postgres   = azurerm_role_assignment.webapp_to_postgres.id
    webapp_to_servicebus = azurerm_role_assignment.webapp_to_servicebus.id
  }
}

output "api_rbac_assignments" {
  description = "Map of all API RBAC assignment IDs"
  value = {
    api_to_acr = azurerm_role_assignment.api_to_acr.id
    #api_to_apim                 = azurerm_role_assignment.api_to_apim.id
    api_to_storage    = azurerm_role_assignment.api_to_storage.id
    api_to_keyvault   = azurerm_role_assignment.api_to_keyvault.id
    api_to_postgres   = azurerm_role_assignment.api_to_postgres.id
    api_to_servicebus = azurerm_role_assignment.api_to_servicebus.id
  }
}

output "n8n_rbac_assignments" {
  description = "n8n RBAC assignment IDs"
  value = {
    n8n_to_acr = azurerm_role_assignment.n8n_to_acr.id
    #n8n_to_apim                 = azurerm_role_assignment.n8n_to_apim.id
    n8n_to_storage    = azurerm_role_assignment.n8n_to_storage.id
    n8n_to_keyvault   = azurerm_role_assignment.n8n_to_keyvault.id
    n8n_to_postgres   = azurerm_role_assignment.n8n_to_postgres.id
    n8n_to_servicebus = azurerm_role_assignment.n8n_to_servicebus.id
  }
}

/*
output "apim_rbac_assignments" {
  description = "APIM RBAC assignment IDs"
  value = {
    apim_to_acr                  = azurerm_role_assignment.apim_to_acr.id
    apim_to_storage              = azurerm_role_assignment.apim_to_storage.id
    apim_to_keyvault             = azurerm_role_assignment.apim_to_keyvault.id
    apim_to_postgres             = azurerm_role_assignment.apim_to_postgres.id
    apim_to_servicebus_sender    = azurerm_role_assignment.apim_to_servicebus_sender.id
    apim_to_servicebus_receiver  = azurerm_role_assignment.apim_to_servicebus_receiver.id
    # apim_to_n8n and apim_to_api are handled via application authentication, not RBAC
  }
}
*/