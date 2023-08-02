variable "project" {
  type        = string
  description = "project name"
}
variable "system_name" {
  type        = string
  description = "System name (bpa, spa, ssd, st2, st3)"
}
variable "env_name" {
  type        = string
  description = "project environment (poc, infra, prd)"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "subscription_id_prd" {
  description = "Provide UK subscription id."
}
variable "tenant_id_prd" {
  description = "Provide UK tenant id."
}
variable "client_id_prd" {
  description = "Provide UK client id."
}

variable "subscription_id" {
  description = "Provide KV subscription id."
}
variable "tenant_id" {
  description = "Provide KV tenant id."
}
variable "client_id" {
  description = "Provide KV client id."
}

variable "sp_object_id" {
  description = "Provide service principal object_id of a user, service principal or security group."
}

variable "env_resource_group_name" {
  type        = string
  description = "project resource group"
}

variable "net_resource_group_name" {
  type        = string
  description = "network resource group owned by IT"
}

variable "devops_resource_group_name" {
  type        = string
  description = "Infrastructure resource group, like Container registry, backups, tf state, dns. The same as BPADO-Infrastructure"
}
variable "networkSubnet" {
  type = string
  description = "Network Subnet"
}
variable "networkName" {
  type = string 
  description = "network Name"
}