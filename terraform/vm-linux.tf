resource "azurerm_network_security_group" "acr_poc_vsg_vm1" {
  name                = "${var.system_name}-${var.project}-vsg_vm1"
  location            = var.location
  resource_group_name = var.env_resource_group_name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ZBX"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "10050"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "fluentd"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "24224"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  tags = local.tags
  depends_on = [ azurerm_resource_group.env_rg ]
}

resource "azurerm_network_interface" "acr_vm1_network_interface" {
  name                = "${var.project}-vm1_network_interface"
  location            = var.location
  resource_group_name = var.env_resource_group_name

  ip_configuration {
    name                          = "${var.project}-vm1_ip_config"
    subnet_id                     = data.azurerm_subnet.env_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.tags
  depends_on = [ azurerm_resource_group.env_rg ]
}

resource "azurerm_network_interface_security_group_association" "network_int_sg_bind" {
  network_interface_id      = azurerm_network_interface.acr_vm1_network_interface.id
  network_security_group_id = azurerm_network_security_group.acr_poc_vsg_vm1.id
}

resource "azurerm_managed_disk" "data_poc_vm1" {
  name                 = "${var.system_name}-${var.project}-vm1_Data_Disk_${random_id.deployment_random_id.hex}"
  location             = var.location
  resource_group_name  = azurerm_resource_group.env_rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb = "32"
  tags         = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "managed_disk_attach_poc_vm1" {
  managed_disk_id    = azurerm_managed_disk.data_poc_vm1.id
  virtual_machine_id = azurerm_linux_virtual_machine.poc_vm1.id
  lun                = 0
  caching            = "ReadWrite"
  depends_on         = [azurerm_managed_disk.data_poc_vm1]
}

data "local_file" "cloudinit_vm1" {
  filename = "./cloudinit.conf"
}

resource "azurerm_linux_virtual_machine" "poc_vm1" {
  name                  = "${var.system_name}-${var.project}-vm1"
  location              = var.location
  resource_group_name   = azurerm_resource_group.env_rg.name
  network_interface_ids = [azurerm_network_interface.acr_vm1_network_interface.id]
  size = "Standard_B2s"
  custom_data = base64encode(data.local_file.cloudinit_vm1.content)

  os_disk {
    name                 = "${var.system_name}-${var.project}_vm1_Disk_${random_id.deployment_random_id.hex}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "32"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "${var.system_name}-${var.project}-vm1"
  admin_username = "adminuser"
  admin_password                  = random_password.random_passwords.result
  disable_password_authentication = false

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.boot.primary_blob_endpoint
  }
  tags = local.tags
  depends_on = [data.local_file.cloudinit_vm1, azurerm_managed_disk.data_poc_vm1]
}

resource "azurerm_key_vault_secret" "acr_vm1_pw" {
  name = "pwvmvm1"
  value = random_password.random_passwords.result
  key_vault_id = azurerm_key_vault.keyvault.id

  depends_on = [azurerm_key_vault_access_policy.sp_vault_app_access_policy, azurerm_key_vault_access_policy.sp_vault_user_access_policy, random_password.random_passwords]
}

resource "azurerm_key_vault_secret" "acr_vm1_ip" {
  name  = "ipvmvm1"
  value = azurerm_linux_virtual_machine.poc_vm1.private_ip_address
  key_vault_id = azurerm_key_vault.keyvault.id

  depends_on = [azurerm_key_vault_access_policy.sp_vault_app_access_policy, azurerm_key_vault_access_policy.sp_vault_user_access_policy, random_password.random_passwords]
}
