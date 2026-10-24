# Virtual Network Module

Creates a Virtual Network with a configurable set of subnets, a dedicated NSG
per subnet (with subnet associations), optional subnet delegations and service
endpoints, and optional NSG diagnostics.

## Features

- `azurerm_virtual_network` with configurable `address_space` and optional
  custom `dns_servers`.
- Subnets from the `subnets` map, each with optional **delegation** (e.g.
  `Microsoft.Web/serverFarms` for App Service / Function VNet integration),
  `service_endpoints`, and `private_endpoint_network_policies` (default
  `Disabled`, as required for private-endpoint subnets).
- One **NSG per subnet**, each associated to its subnet, with optional
  `security_rules`.
- Optional **NSG diagnostics** to Log Analytics (pass `log_analytics_workspace_id`;
  left null by default to avoid a dependency cycle when the workspace itself
  depends on this VNet - the root wires NSG diagnostics after both exist).

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name` | VNet name. | `string` | n/a |
| `address_space` | CIDR list. | `list(string)` | n/a |
| `dns_servers` | Custom DNS servers. | `list(string)` | `[]` |
| `subnets` | Map of subnet name => { address_prefixes, delegation, service_endpoints, private_endpoint_network_policies, security_rules }. | `map(object)` | n/a |
| `log_analytics_workspace_id` | Optional workspace for NSG diagnostics. | `string` | `null` |

## Outputs

| Name | Description |
|------|-------------|
| `vnet_id` | VNet resource ID. |
| `vnet_name` | VNet name. |
| `address_space` | VNet address space. |
| `subnet_ids` | Map subnet name => ID. |
| `nsg_ids` | Map subnet name => NSG ID. |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_virtual_network` | 1 |
| `azurerm_subnet` | per subnet |
| `azurerm_network_security_group` | per subnet |
| `azurerm_subnet_network_security_group_association` | per subnet |
| `azurerm_monitor_diagnostic_setting` | 0 or per subnet |

## Providers

`hashicorp/azurerm`
