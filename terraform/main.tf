locals {
  tags = {
    project     = var.project
    managed     = "terraform"
    created     = "iag2009"
    environment = var.env_name
    system_name = var.system_name
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "env_rg" {
  name     = var.env_resource_group_name
  location = var.location
  tags = local.tags
}

resource "random_password" "random_passwords" {
  length      = 16
  special     = false
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  override_special = "!?-_=+"
}
resource "random_id" "deployment_random_id" {
  byte_length = 3
}

resource "time_sleep" "wait_15_seconds" {
  create_duration = "15s"
}

resource "azurerm_storage_account" "boot" {
  name                     = "boot${random_id.deployment_random_id.hex}"
  resource_group_name      = azurerm_resource_group.env_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
  depends_on = [ azurerm_resource_group.env_rg ]
}
