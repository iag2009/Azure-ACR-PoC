resource "random_password" "random_passwords" {
  length      = 16
  special     = false
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
}
resource "random_id" "deployment_random_id" {
    byte_length = 3
}

resource "time_sleep" "wait_15_seconds" {
  create_duration = "15s"
}

resource "azurerm_storage_account" "boot" {
  name                        = "boot${random_id.deployment_random_id.hex}"
  resource_group_name         = var.env_resource_group_name
  location                    = var.location
  account_tier                = "Standard"
  account_replication_type    = "LRS"
  tags                        = local.tags
}
