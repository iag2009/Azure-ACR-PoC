variable "project" {
  type    = string
  description = "project name"
  
}
variable "environment" {
  type    = string
  description = "project environment (poc, prod)"
}

variable "location" {
  type    = string
  description = "Azure region"
}

variable "rg_name" {
  type    = string
  description = "resource group name"
}

variable "subscription_id" {
  description = "Provide main subscription id."
  default     = "6014efee-0ecc-42d2-9874-04fcb1972096"
}

variable "tenant_id" {
  description = "Provide tenant id."
  default     = "0addea55-b056-465d-b7a7-f09eb3345933"
}

variable "client_id" {
  description = "Provide client id."
}
