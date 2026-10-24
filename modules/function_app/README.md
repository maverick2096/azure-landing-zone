# Function App (Linux) Module

Creates a **private-only** Linux Function App on its **own dedicated App Service
Plan**, with regional VNet integration, a private endpoint, diagnostics, and the
workload managed identity attached.

## Features

- Creates a dedicated `azurerm_service_plan` (Linux) - per project design each
  app owns its plan.
- Function app: `https_only = true`, `public_network_access_enabled = false`,
  TLS floor, `always_on`, `ftps_state = Disabled`, `vnet_route_all_enabled`.
- Backing storage account passed in (`storage_account_name` +
  `storage_account_access_key`) - reuse the `storage_account` module.
- Optional runtime stack: set exactly one of `node_version` / `python_version`
  / `dotnet_version` / `java_version`.
- Regional **VNet integration** via `vnet_integration_subnet_id` (outbound).
- **Private endpoint on the `sites` sub-resource** (inbound), registered in the
  **existing** private DNS zone(s) via `private_dns_zone_ids`.
- **Managed identity**: SystemAssigned + any `user_assigned_identity_ids`.
- **Diagnostic settings** (all logs + metrics) on the function app.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name                          | Description                                           | Type           | Default   |
|-------------------------------|-------------------------------------------------------|----------------|-----------|
| `function_app_name`           | Function app name.                                    | `string`       | n/a       |
| `plan_name`                   | Name of the dedicated plan this app creates.          | `string`       | n/a       |
| `plan_sku_name`               | Plan SKU.                                             | `string`       | `P1v3`    |
| `storage_account_name`        | Backing storage account name.                         | `string`       | n/a       |
| `storage_account_access_key`  | Backing storage access key (sensitive).               | `string`       | n/a       |
| `node_version` / `python_version` / `dotnet_version` / `java_version` | Runtime (set one). | `string` | `null` |
| `private_endpoint_subnet_id`  | Subnet for the private endpoint.                      | `string`       | n/a       |
| `private_dns_zone_ids`        | Existing `privatelink.azurewebsites.net` zone ID.     | `list(string)` | n/a       |
| `vnet_integration_subnet_id`  | Delegated subnet for VNet integration.                | `string`       | `null`    |
| `log_analytics_workspace_id`  | Workspace ID for diagnostics.                         | `string`       | n/a       |
| `application_insights_connection_string` | App Insights connection string.           | `string`       | `null`    |
| `user_assigned_identity_ids`  | Managed identity IDs to attach.                       | `list(string)` | `[]`      |

## Outputs

| Name                    | Description                               |
|-------------------------|-------------------------------------------|
| `id`                    | Function app resource ID.                 |
| `name`                  | Function app name.                        |
| `default_hostname`      | Default hostname.                         |
| `service_plan_id`       | Dedicated plan ID.                        |
| `identity_principal_id` | System-assigned identity principal ID.    |
| `private_endpoint_id`   | Function app PE resource ID.              |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_linux_function_app` | 1 |
| `azurerm_monitor_diagnostic_setting` | 1 |
| `azurerm_private_endpoint` | 1 |
| `azurerm_service_plan` | 1 |

## Providers

`hashicorp/azurerm`
