
output "azurerm_client_config_current_tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
output "azurerm_client_config_current_object_id" {
  value = data.azurerm_client_config.current.object_id
}
output "azurerm_key_vault-keyvault-rg" {
  value = azurerm_key_vault.keyvault.resource_group_name
  description = "Key Vault Resource Group"
}
output "azurerm_key_vault-keyvault-name" {
    value = azurerm_key_vault.keyvault.name
    description = "Key Vault name"
}
output "azurerm_key_vault-keyvault-vault_uri" {
    value = azurerm_key_vault.keyvault.vault_uri
    description = "Key Vault URI"
}
output "azurerm_storage_account" {
  value = azurerm_storage_account.boot
  description = "storage account for vm"
  sensitive = true
}
output "network_interface_id_poc_vm1" {
  value = azurerm_network_interface.poc_vm1_network_interface.id
}

output "network_interface_private_ip_address_poc_vm1" {
  value = azurerm_network_interface.poc_vm1_network_interface.private_ip_address
}
