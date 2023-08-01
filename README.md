# Azure Resource Creation using Terraform

This repository contains various Terraform configuration files that automate the creation of Azure resources such as Container Registry, VMs, a Key Vault for storing secrets and a Key Vault access policy. This setup forms a part of the runtime platform resource creation stage.

## Prerequisites

- Terraform CLI installed locally
- Azure CLI 2.0 or higher
- Access to an Azure subscription and permissions to create and manage resources

## Repository Structure

- `ansible_inventory.tf` - Generates an Ansible inventory file from the created VMs.
- `cloudinit.conf` - Contains cloud-init configuration for VM setup.
- `main.tf` - The main Terraform configuration file that includes all modules.
- `provider.tf` - Defines the Azure provider for Terraform.
- `secrets.tf` - Handles secrets in Azure Key Vault.
- `variables.tf` and `variables_prd.tf` - Contain variable definitions that are used across the configuration files.
- `vault_access_policy.tf` - Defines the Key Vault access policy.
- `vm-linux.tf` - Defines the Azure Linux VM resource.

## Usage

1. Run Runtime Platform by using autobot created pipeline

## Contributing

For major changes, please open an task first and inform Devops team to discuss what you would like to change.

## Support

If you encounter any problems, please contact BPA DevOps Team.

## Acknowledgments

- BPA DevOps Team 
