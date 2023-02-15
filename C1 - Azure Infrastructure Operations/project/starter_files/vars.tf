variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "clouddev"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "West Europe"
}

/* variable "ressource_group" {
  description = "Ressource Group of Udacity classe"
  default     = "default-rg"
} */

variable "tags" {
  description = "Map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    project = "udacity"
  }
}

variable "application_port" {
  description = "Port that you want to expose to the external load balancer"
  default     = 80
}

variable "ssh_port" {
  description = "Port that you want to expose to the external load balancer"
  default     = 22
}

variable "admin_user" {
  description = "User name to use as the admin account on the VMs that will be part of the VM scale set"
  default     = "azureuser"
}

variable "admin_password" {
  description = "Default password for admin account"
}


variable "subscription_id" {
  description = "Default password for admin account"
  default     = env.ARM_SUBSCRIPTION_ID
}

variable "tenant_id" {
  description = "Default password for admin account"
  default     = env.ARM_TENANT_ID
}

variable "client_id " {
  description = "Default password for admin account"
  default     = env.env.ARM_CLIENT_ID
}

variable "client_secret" {
  description = "Default password for admin account"
  default     = env.ARM_CLIENT_SECRET
}

variable "instance_count" {
  description = "minimum amount of vms to be deployed "
  default     = 2
}
