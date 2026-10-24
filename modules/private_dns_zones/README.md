# Private DNS Zones Module

Creates a set of **private DNS zones once** and links each of them to **every
VNet** supplied in `vnet_links`. Private DNS zones are global, so for a
multi-region / peered deployment a single zone is linked to all region VNets
(rather than duplicating zones per region).

## Features

- One `azurerm_private_dns_zone` per entry in `zone_names`.
- One `azurerm_private_dns_zone_virtual_network_link` per **zone × VNet**
  (registration disabled - resolution only).

> The Azure Monitor (`privatelink.monitor.azure.com`, `oms`, `ods`, `agentsvc`)
> zones are **not** created here - the `log_analytics` module owns those, linked
> to its own region VNet, because they are tied to the regional AMPLS.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `zone_names` | Zone names to create. | `list(string)` | n/a |
| `resource_group_name` | RG to hold the zones. | `string` | n/a |
| `vnet_links` | Map of link key => VNet ID; every zone links to every VNet. | `map(string)` | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `zone_ids` | Map of zone name => zone resource ID (feed the service modules). |
| `zone_names` | List of created zone names. |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_private_dns_zone` | per zone |
| `azurerm_private_dns_zone_virtual_network_link` | zone × VNet |

## Providers

`hashicorp/azurerm`
