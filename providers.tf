terraform {
  required_version = ">= 1.14.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.54"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  # subscription_id is taken from the ARM_SUBSCRIPTION_ID env var / CLI context
  environment = "public"
  use_msi     = true
  #features {
  #  storage {
  #    use_azuread_auth = true
  #  }
  #}
}

#use_oidc = true
#skip_provider_registration = true
#use_oidc = true
#skip_provider_registration = true