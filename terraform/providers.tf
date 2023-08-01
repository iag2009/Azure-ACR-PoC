terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.1"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "bpa-devops-rg"
    storage_account_name = "bpatfstatestore"
    container_name       = "terraform-state"
    key                  = "bpa.infra.acr.tfstate"
    # Use Subscription pointed by ARM_ACCESS_KEY, not by provider "azurerm"
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  tenant_id       = var.tenant_id
  features {}
  # Provide provider client_secret value by ARM_CLIENT_SECRET varible.
}

provider "azurerm" {
  alias           = "DaInc"
  subscription_id = var.subscription_id_prd
  client_id       = var.client_id_prd
  tenant_id       = var.tenant_id_prd
  // client_secret   = var.client_secret_prd
  features {}
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}
