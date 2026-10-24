# Log Analytics Module

Creates a **private-only** Log Analytics workspace and the **Azure Monitor
Private Link Scope (AMPLS)** that fronts it. This module is the owner of the
monitor private DNS zones for the platform.

## Features

- Workspace with `internet_ingestion_enabled = false` and
  `internet_query_enabled = false` (no public access).
- **AMPLS** (`PrivateOnly` ingestion + query) with the workspace linked as a
  scoped service.
- Creates and VNet-links the four monitor private DNS zones:
  `privatelink.monitor.azure.com`, `privatelink.oms.opinsights.azure.com`,
  `privatelink.ods.opinsights.azure.com`,
  `privatelink.agentsvc.azure-automation.net`.
- **Private endpoint** to the AMPLS (`azuremonitor` sub-resource). Optionally
  includes a shared, existing blob private DNS zone for the agent download path.
- **Diagnostic settings** on the workspace.

> App Insights attaches to this AMPLS - pass `ampls_id` into the `app_insights`
> module. Other modules send their diagnostics here via
> `log_analytics_workspace_id`.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name                         | Description                                           | Type     | Default       |
|------------------------------|-------------------------------------------------------|----------|---------------|
| `name`                       | Workspace name.                                       | `string` | n/a           |
| `sku`                        | Workspace SKU.                                        | `string` | `PerGB2018`   |
| `retention_days`             | Retention in days.                                    | `number` | `30`          |
| `virtual_network_id`         | VNet to link monitor DNS zones to.                    | `string` | n/a           |
| `private_endpoint_subnet_id` | Subnet for the AMPLS private endpoint.                | `string` | n/a           |
| `ingestion_access_mode`      | AMPLS ingestion mode.                                 | `string` | `PrivateOnly` |
| `query_access_mode`          | AMPLS query mode.                                     | `string` | `PrivateOnly` |
| `blob_private_dns_zone_id`   | Optional shared blob zone ID for AMPLS.               | `string` | `null`        |

## Outputs

| Name                           | Description                                 |
|--------------------------------|---------------------------------------------|
| `log_analytics_workspace_id`   | Workspace ID (feed other modules).          |
| `log_analytics_workspace_name` | Workspace name.                             |
| `ampls_id`                     | AMPLS ID (feed the app_insights module).    |
| `monitor_private_dns_zone_ids` | Map of created monitor zone IDs.            |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_log_analytics_workspace` | 1 |
| `azurerm_monitor_diagnostic_setting` | 1 |
| `azurerm_monitor_private_link_scope` | 1 |
| `azurerm_monitor_private_link_scoped_service` | 1 |
| `azurerm_private_dns_zone` | 1 |
| `azurerm_private_dns_zone_virtual_network_link` | 1 |
| `azurerm_private_endpoint` | 1 |

## Providers

`hashicorp/azurerm`
