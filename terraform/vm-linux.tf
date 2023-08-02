locals {
  project = "acr"
  managed = "terraform"
  created   = "ailves"
  environment = var.env_name
  system_name = var.system_name
  CostCenter  = "BPA"
}
# --- "acr_{{envName}}_vsg_{{vmName}}" definitions
#  envName = "poc"
#  vmName = "vm1"  

resource "azurerm_network_security_group" "acr_poc_vsg_vm1" {
  name                = "acr_poc_vsg_vm1"
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

  #This for cycle renders port list passed in ports structure
/*
{%- for port in ports %}
  security_rule {
    name                       = "port{{port.num}}"
    priority                   = {{port.pri}}
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "{{port.num}}"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
{%- endfor %}
*/
  tags = local.tags
}

resource "azurerm_network_interface" "poc_vm1_network_interface" {
  name                      = "poc_vm1_network_interface"
  location                  = var.location
  resource_group_name       = var.env_resource_group_name

  ip_configuration {
    name                          = "poc_vm1_ip_config"
    subnet_id                     = data.azurerm_subnet.env_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.tags
}

resource "azurerm_network_interface_security_group_association" "poc_vm1_bind" {
  network_interface_id      = azurerm_network_interface.poc_vm1_network_interface.id
  network_security_group_id = azurerm_network_security_group.acr_poc_vsg_vm1.id
}
# {% if vm.volumeStorage|length %}
resource "azurerm_managed_disk" "data_poc_vm1" {
  name                 = "acr_poc_vm1_Data_Disk_${random_id.deployment_random_id.hex}"
  location             = var.location
  resource_group_name  = var.env_resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  # disk_size_gb         = "{{vm.volumeStorage}}"
  disk_size_gb         = "32"
  tags = local.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "managed_disk_attach_poc_vm1" {
  managed_disk_id    = azurerm_managed_disk.data_poc_vm1.id
  virtual_machine_id = azurerm_linux_virtual_machine.poc_vm1.id
  lun                = 0
  caching            = "ReadWrite"
  depends_on      = [ azurerm_managed_disk.data_poc_vm1 ]
}

data "local_file" "cloudinit_vm1" {
  filename = "./cloudinit.conf"
}
# {% endif %}
resource "azurerm_linux_virtual_machine" "poc_vm1" {
  name                   = "acr_poc_vm1"
  location               = var.location
  resource_group_name    = var.env_resource_group_name
  network_interface_ids  = [azurerm_network_interface.poc_vm1_network_interface.id ]
  # size                   = "{{vmSize}}"
  size                = "Standard_B2s"
  # {%- if vm.volumeStorage|length %}
  custom_data            = base64encode(data.local_file.cloudinit_vm1.content)
  # {%- endif %}

  os_disk {
    name                 = "acr_poc_vm1_Disk_${random_id.deployment_random_id.hex}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb        = "32"
  }

  # Use e.g.
  #   az vm image list --all --publisher="Canonical" --sku="20_04-lts-gen2"
  # to fetch/verify image list

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # computer_name  = "{{envName}}-{{vmName}}"
  computer_name  = "acr-poc-vm1"
  admin_username = "adminuser"
  # admin_password = random_password.random_passwords[{{num}}].result
  admin_password = random_password.random_passwords.result
  disable_password_authentication = false

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.boot.primary_blob_endpoint
  }
  tags = local.tags
# {%- if vm.volumeStorage|length %}
  depends_on      = [ data.local_file.cloudinit_vm1, azurerm_managed_disk.data_poc_vm1 ]
# {%- endif %}
}

resource "azurerm_key_vault_secret" "poc_vm1_pw" {
  name         = "pwvmvm1"
#  value        = random_password.random_passwords[{{num}}].result
  value        = random_password.random_passwords.result
#  key_vault_id = azurerm_key_vault.vault.id
  key_vault_id = azurerm_key_vault.keyvault.id

#  depends_on   = [ time_sleep.wait_15_seconds, random_password.random_passwords[{{num}}] ]
  depends_on = [azurerm_key_vault_access_policy.sp_vault_app_access_policy, azurerm_key_vault_access_policy.sp_vault_user_access_policy, random_password.random_passwords]
}

resource "azurerm_key_vault_secret" "poc_vm1_ip" {
  name         = "ipvmvm1"
  value        = azurerm_linux_virtual_machine.poc_vm1.private_ip_address
#  key_vault_id = azurerm_key_vault.vault.id
  key_vault_id = azurerm_key_vault.keyvault.id

  depends_on = [azurerm_key_vault_access_policy.sp_vault_app_access_policy, azurerm_key_vault_access_policy.sp_vault_user_access_policy, random_password.random_passwords]
}
