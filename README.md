# Azure Landing-Zone Terraform Modules

Reusable Terraform modules and a root composition for deploying a **private, no-public-endpoint** application platform on **public Azure** (azurerm provider, `~> 4.54`).

Every network-capable resource is deployed with:

- **No public access** — `public_network_access_enabled = false` (Log Analytics / App Insights use private-only ingestion + query via an Azure Monitor Private Link Scope).
- **A private endpoint** registered in an **existing** private DNS zone (link-to-existing pattern — you supply the zone IDs).
- **Diagnostic settings** streamed to a central **Log Analytics workspace**.
- A tuned **`lifecycle { ignore_changes }`** block to prevent drift churn.
- Data-plane **RBAC / access policies** granted to a shared **user-assigned managed identity**.

## Repository layout

```
.
├── main.tf                 # Root composition — wires the modules together
├── variables.tf            # Root inputs (names, toggles, networking)
├── variables_platform.tf   # Platform inputs (managed identity, DNS zone IDs, Function App)
├── providers.tf            # azurerm (public cloud) + local + tls, version pins
├── backend.tf              # Remote state (azurerm backend)
├── locals.tf               # build_date
├── terraform.tfvars        # Values — fill in the <PLACEHOLDER> items before applying
├── pipelines/              # Azure DevOps per-module build pipelines
└── modules/                # Reusable modules (standard 5-file layout)
    └── <module>/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── versions.tf      # required_version + required_providers (azurerm ~> 4.54)
        ├── README.md
        └── examples/usage.tf
```

## Modules

| Module | Purpose | Private endpoint | Notes |
|--------|---------|------------------|-------|
| [`resource_group`](modules/resource_group) | Resource group | n/a | container only |
| [`managed_identity`](modules/managed_identity) | User-assigned managed identity | n/a | the platform workload identity |
| [`key_vault`](modules/key_vault) | Key Vault | `vault` | access policies to the managed identity |
| [`log_analytics`](modules/log_analytics) | Log Analytics workspace + **AMPLS** | `azuremonitor` | owns the monitor private DNS zones |
| [`app_insights`](modules/app_insights) | Application Insights | via AMPLS | workspace-based, private |
| [`storage_account`](modules/storage_account) | Storage account | `blob` | MI → Blob Data Contributor |
| [`app_service_plan`](modules/app_service_plan) | Standalone App Service Plan | n/a | optional / shared plan |
| [`function_app`](modules/function_app) | Linux Function App (own plan) | `sites` | MI attached |
| [`app_service`](modules/app_service) | Linux Web App (own plan) | `sites` | MI attached |
| [`service_bus`](modules/service_bus) | Service Bus (Premium) | `namespace` | MI → Data Owner |
| [`acr`](modules/acr) | Container Registry (Premium) | `registry` | MI → AcrPull |
| [`document_intelligence`](modules/document_intelligence) | Azure AI Document Intelligence (Cognitive Services) | `account` | MI → Cognitive Services User |
| [`virtual_machine`](modules/virtual_machine) | Standalone VM (Windows/Linux) | n/a (private NIC) | Azure Monitor Agent; per-VM via `vm_configurations` |
| [`virtual_network`](modules/virtual_network) | VNet + subnets + per-subnet NSGs | n/a | created per region; feeds subnet IDs to every module |
| [`private_dns_zones`](modules/private_dns_zones) | Service private DNS zones + VNet links | n/a | created once, linked to all region VNets |

> The repo also contains additional, pre-existing modules (api_management, load_balancer, network_security_group, postgresql_flex, private_dns, private_link_service, public_ip, rbac, recovery_vault, frontdoor) used by the root but outside the standardized set above.

Each module has its own `README.md` with inputs, outputs, resources and a copy-paste example in `examples/usage.tf`.

## Prerequisites

The platform is **self-contained** — it creates its own networking (VNet,
subnets, NSGs) and private DNS zones. You only need:

1. An **Azure subscription** and credentials for the azurerm provider. The
   provider is configured with `use_msi = true` (managed identity on the
   pipeline agent); set `ARM_SUBSCRIPTION_ID` (and tenant/auth) in the
   environment.
2. An **Azure Storage account** for Terraform remote state (see `backend.tf`).
3. **Private connectivity from wherever you run Terraform / deploy apps** — with
   public access disabled, self-hosted/private build agents (or equivalent) are
   required to reach Key Vault, Storage, ACR, the apps, etc.

What the configuration **creates** (so you no longer supply these):

- A **VNet per region** with a private-endpoint subnet, a delegated
  (`Microsoft.Web/serverFarms`) app-integration subnet, and a VM subnet
  (`virtual_network` module). CIDRs default to `10.0.0.0/16` (primary) /
  `10.1.0.0/16` (DR) — override via `vnet_address_space` / `dr_vnet_address_space`.
- The **service private DNS zones** (vaultcore, blob, azurecr, servicebus,
  azurewebsites, cognitiveservices), created once and linked to every region
  VNet (`private_dns_zones` module). The **monitor** zones are created by the
  `log_analytics` module.
- When `enable_dr = true`: the DR VNet plus **global VNet peering** between the
  two regions.

## Getting started

1. Fill in the remaining placeholders in [`terraform.tfvars`](terraform.tfvars):
   - `location`, resource names, tags
   - `managed_identity_name`, `app_insights_name`, Function App settings
   - `app_image_name*` (`REPLACE_WITH_IMAGE_NAME`) and the VM / `postgres` passwords (`CHANGE_ME_BEFORE_APPLY`) where those resources are enabled
   - optionally the VNet address spaces if the `10.x` defaults clash

2. Initialize, validate, plan, apply:

   ```bash
   terraform init
   terraform validate
   terraform fmt -check -recursive
   terraform plan  -out tfplan
   terraform apply tfplan
   ```

   To validate without the remote backend (e.g. in CI linting): `terraform init -backend=false`.

## Disaster recovery (second region)

Set `enable_dr = true` and `dr_location` to deploy a **full standby copy** of the
platform in a second region. The root `main.tf` loops every in-scope module over
a `local.regions` map (`primary`, and `dr` when enabled) — the DR logic lives in
the root, not in the modules. DR resources reuse the **same input variables**;
only the **region changes** to `dr_location`, and every DR resource name gets the
`dr_resource_suffix` (default `-dr`; stripped to `dr` for name-constrained
resources like Storage and ACR).

```hcl
enable_dr   = true
dr_location = "westus"
```

DR networking is handled automatically: the `virtual_network` module creates a
**separate VNet + subnets + NSGs in `dr_location`** (address space
`dr_vnet_address_space`), the two VNets are **peered**, and the shared private
DNS zones are linked to both. So DR deploys end-to-end with no manual networking
inputs — just set `enable_dr = true` and `dr_location`.

## Conventions

- **Provider pin:** every module declares `versions.tf` with `required_version >= 1.14.0` and `azurerm ~> 4.54`. The modules are **not** compatible with azurerm v5.x without changes (v5 removed `metric` blocks, renamed several attributes, etc.).
- **Diagnostics** use `enabled_metric` / `enabled_log` (the v4 non-deprecated form).
- **Lifecycle:** the web/function apps ignore `app_settings`, `site_config`, `sticky_settings`, `connection_string` and `virtual_network_subnet_id`. Consequence: **runtime config and image-tag changes do not flow through Terraform** after creation — deploy those via your release pipeline/CLI.
- **Toggles:** most root modules are gated by `build_*` booleans (see `variables.tf`). Core prerequisites (`build_resource_group`, `build_log_analytics`, managed identity) are expected to stay enabled.

## Security posture

- No public endpoints on any PE-capable resource; Key Vault & Storage default-deny network ACLs; Service Bus `local_auth_enabled = false`; ACR & Service Bus `Premium` (required for private endpoints).
- Log Analytics & App Insights are private-only through a shared AMPLS.
- Secrets are **not** committed — `terraform.tfvars` holds placeholders; real secrets/state live outside source control. See [`.gitignore`](.gitignore).
- State may contain secrets — keep the backend storage account locked down (no public access, RBAC-scoped, versioned).
