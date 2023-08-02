locals {
  tags = {
    project = "ACR"
    created = "terraform"
    owner   = "ailves"
  }
}

# Datasource-1: To get Azure Tenant Id
data "azurerm_client_config" "current" {}

# Azure Key Vault
resource "azurerm_key_vault" "keyvault" {
  name                            = "bpa-vault-acr"
  location                        = var.location
  resource_group_name             = var.devops_resource_group_name
  enabled_for_disk_encryption     = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  enabled_for_template_deployment = true
  sku_name                        = "standard"

  tags = local.tags
  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

# Azure Key Vault access policy with Admin permissions for Terraform Service Principal
resource "azurerm_key_vault_access_policy" "sp_vault_user_access_policy" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  lifecycle {
    create_before_destroy = true
  }
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge",
    "Recover",
    "Backup",
    "Restore"
  ] 
  depends_on = [azurerm_key_vault.keyvault]
}

# Azure Key Vault access policy for DevOps App Service Principal
resource "azurerm_key_vault_access_policy" "sp_vault_app_access_policy" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.sp_object_id

  lifecycle {
    create_before_destroy = true
  }
  secret_permissions = [
    "Get",
    "Set",
    "Purge",
    "Recover",
    "Delete",
  ]
  depends_on = [azurerm_key_vault.keyvault]
}
