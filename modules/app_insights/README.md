# Application Insights Module

Creates a **workspace-based**, **private-only** Application Insights component
and attaches it to the Azure Monitor Private Link Scope (AMPLS) created by the
`log_analytics` module.

## Features

- Workspace-based (`workspace_id` points at the Log Analytics workspace).
- `internet_ingestion_enabled = false` and `internet_query_enabled = false`
  (no public access) - telemetry reaches it through the AMPLS private endpoint.
- Linked to the AMPLS via `azurerm_monitor_private_link_scoped_service`.

> App Insights has no private endpoint of its own; private connectivity is
> provided by the shared AMPLS. Make sure the `log_analytics` module (AMPLS +
> monitor private DNS zones + private endpoint) is deployed first.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name                         | Description                                 | Type     | Default |
|------------------------------|---------------------------------------------|----------|---------|
| `app_insights_name`          | Component name.                             | `string` | n/a     |
| `application_type`           | App Insights application type.              | `string` | `web`   |
| `log_analytics_workspace_id` | Backing workspace ID.                       | `string` | n/a     |
| `ampls_name`                 | AMPLS name to attach to.                    | `string` | n/a     |

## Outputs

| Name                  | Description                               |
|-----------------------|-------------------------------------------|
| `id`                  | Component resource ID.                    |
| `app_id`              | App ID.                                   |
| `instrumentation_key` | Instrumentation key (sensitive).          |
| `connection_string`   | Connection string (sensitive).            |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_application_insights` | 1 |
| `azurerm_monitor_private_link_scoped_service` | 1 |

## Providers

`hashicorp/azurerm`
