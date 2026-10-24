# App Service Plan Module

Creates an Azure App Service Plan with diagnostics and optional autoscale.

> **Note on private endpoints:** a plan is compute capacity and has no private
> endpoint. Private networking is applied to the apps that run on the plan
> (`app_service` / `function_app` modules) via VNet integration + private
> endpoints.
>
> Per the project design, the `app_service` and `function_app` modules each
> create their own plan. This standalone module is kept for the case where you
> want a **shared** plan referenced by multiple apps.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name                         | Description                         | Type     | Default |
|------------------------------|-------------------------------------|----------|---------|
| `plan_name`                  | Plan name.                          | `string` | n/a     |
| `os_type`                    | `Linux` or `Windows`.               | `string` | `Linux` |
| `sku_name`                   | Plan SKU.                           | `string` | `P1v3`  |
| `log_analytics_workspace_id` | Workspace ID for diagnostics.       | `string` | n/a     |
| `enable_autoscale`           | Create an autoscale setting.        | `bool`   | `false` |
| `autoscale_*`                | Capacity / CPU thresholds.          | `number` | see vars|

## Outputs

| Name      | Description                     |
|-----------|---------------------------------|
| `id`      | Plan resource ID.               |
| `name`    | Plan name.                      |
| `os_type` | Plan OS type.                   |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_monitor_autoscale_setting` | 1 |
| `azurerm_monitor_diagnostic_setting` | 1 |
| `azurerm_service_plan` | 1 |

## Providers

`hashicorp/azurerm`
