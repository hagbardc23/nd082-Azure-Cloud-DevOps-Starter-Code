variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "clouddev"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "West Europe"
}

variable "image_name" {
  description = "VM Image name"
  default     = "HeloWorldWebServerImage"
}

variable "image_ressource_group" {
  description = "Ressource Group of the vm image"
  default     = "default-rg"
}

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    environment = "dev"
  }
}

variable "application_port" {
  description = "Port for netwrok security rules for access to the application"
  default     = 80
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs"
  default     = "azureuser"
}

variable "subscription_id" {
  description = "Azure Subscription Id"
}

variable "tenant_id" {
  description = "Azure Tenant Id"
}

variable "client_id" {
  description = "Azure Service Principal Application Id"
}

variable "client_secret" {
  description = "Azure Service Principal Application password"
}

variable "instance_count" {
  description = "minimum amount of vms to be deployed "
  default     = 2
}
