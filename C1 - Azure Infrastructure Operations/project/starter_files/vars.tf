variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "udacity"
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be created."
  default     = "West Europe"
}

variable "username" {
  description = "The username for azure portal authentication"
  default     = "23xxx@gmx.de"
}

variable "password" {
  description = "The password for azure portal authentication"
  default     = "8cx0-5TdAg"
}

variable "ressource_group" {
  description = "Ressource Group of Udacity classe"
  default     = "default-ng"
}
