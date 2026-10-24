# Virtual Machine Module

Creates a single **standalone virtual machine** — **Windows or Linux** — with a
**private-only** NIC (no public IP), optional managed identity, boot
diagnostics, and Azure Monitor Agent telemetry to Log Analytics. Intended to be
called per-VM via `for_each` from the root (`var.vm_configurations`).

## Features

- **Windows or Linux** selected by `os_type` (one VM resource is created
  accordingly).
- **No public IP** — the NIC has a single private IP configuration in
  `subnet_id` (Dynamic or Static).
- **Authentication:** Linux uses `ssh_public_key` when provided (password auth
  disabled) and falls back to `admin_password`; Windows uses
  `admin_username` / `admin_password`. Source passwords from Key Vault or a
  pipeline variable - never from source control.
- **Managed identity:** system-assigned (default) and/or
  `user_assigned_identity_ids`.
- **Boot diagnostics:** enabled by default (managed storage unless
  `boot_diagnostics_storage_account_uri` is set).
- **Monitoring:** installs the **Azure Monitor Agent** extension
  (`enable_monitoring`) and, when `data_collection_rule_id` is supplied,
  associates the VM with that DCR to route guest telemetry to Log Analytics.
- Optional `availability_set_id` or `zone`; Windows `patch_mode` configurable.

> VMs do not support `azurerm_monitor_diagnostic_setting` at the resource level;
> guest metrics/logs are collected through the Azure Monitor Agent + a Data
> Collection Rule, which is why this module takes `data_collection_rule_id`
> rather than creating a diagnostic setting.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `vm_name` | VM name. | `string` | n/a |
| `os_type` | `Windows` or `Linux`. | `string` | n/a |
| `vm_size` | VM SKU. | `string` | `Standard_D2s_v5` |
| `admin_username` | Admin username. | `string` | n/a |
| `admin_password` | Admin password (Windows; Linux w/o key). | `string` | `""` |
| `ssh_public_key` | SSH public key (Linux). | `string` | `""` |
| `subnet_id` | Subnet for the private NIC. | `string` | n/a |
| `private_ip_allocation` / `private_ip` | Dynamic or Static (+ IP). | `string` | `Dynamic` |
| `image_publisher` / `image_offer` / `image_sku` / `image_version` | Marketplace image. | `string` | n/a / `latest` |
| `os_disk_*` | Caching / type / size / name. | — | Premium_LRS, 128 GB |
| `availability_set_id` / `zone` | Placement. | `string` | `null` |
| `enable_system_assigned_identity` / `user_assigned_identity_ids` | Identity. | — | `true` / `[]` |
| `enable_boot_diagnostics` / `boot_diagnostics_storage_account_uri` | Boot diag. | — | `true` / managed |
| `enable_monitoring` / `automatic_extension_upgrade_enabled` | Azure Monitor Agent. | `bool` | `true` |
| `log_analytics_workspace_id` | Telemetry target (via DCR). | `string` | `null` |
| `data_collection_rule_id` | DCR to associate. | `string` | `null` |
| `patch_mode` | Windows patch mode. | `string` | `AutomaticByPlatform` |

## Outputs

| Name | Description |
|------|-------------|
| `id` | VM resource ID. |
| `name` | VM name. |
| `private_ip_address` | NIC private IP. |
| `nic_id` | NIC resource ID. |
| `identity_principal_id` | System-assigned identity principal ID (or null). |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_network_interface` | 1 |
| `azurerm_windows_virtual_machine` or `azurerm_linux_virtual_machine` | 1 |
| `azurerm_virtual_machine_extension` (Azure Monitor Agent) | 0–1 |
| `azurerm_monitor_data_collection_rule_association` | 0–1 |

## Providers

`hashicorp/azurerm`
