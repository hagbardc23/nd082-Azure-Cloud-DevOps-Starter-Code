/* Azure required_provider with source and version  */
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
/* service principal & account informations */
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
  client_secret   = var.client_secret
}

/* 
 Definition of resource group
 */
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
  tags     = var.tags
}

/* Randomized string for fqdn assignment */
resource "random_string" "fqdn" {
  length  = 6
  special = false
  upper   = false
  numeric  = false
}

/* 
 Definitions of virtual network, its subnet, public ip adress and network interfaces for all instances
 */
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  domain_name_label   = random_string.fqdn.result
  tags                = var.tags
}

resource "azurerm_network_interface" "main" {
  count               = var.instance_count
  name                = "${var.prefix}-nic${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

/* 
 Definition of availability set
 */
resource "azurerm_availability_set" "avset" {
  name                         = "${var.prefix}-avset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true

  tags = var.tags
}

/* 
 Definitions of network security group and its security rules
 */
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = var.tags
}

resource "azurerm_network_security_rule" "outbound" {
  name                        = "${var.prefix}-outbound_rule"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.application_port
  source_address_prefix       = azurerm_subnet.internal.address_prefixes[0]
  destination_address_prefix  = "VirtualNetwork"

}

resource "azurerm_network_security_rule" "inbound" {
  name                        = "${var.prefix}-inbound_rule"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = var.application_port
  source_address_prefix       = "Internet"
  destination_address_prefix  = azurerm_subnet.internal.address_prefixes[0]
}

resource "azurerm_network_interface_security_group_association" "main" {
  count                = var.instance_count
  network_interface_id = azurerm_network_interface.main[count.index].id
  /* subnet_id                 = azurerm_subnet.internal.id */
  network_security_group_id = azurerm_network_security_group.main.id
}

/* 
 Definitions of Loadbalancer and its components like backend adress pool, nat_rule
 */
resource "azurerm_lb" "main" {
  name                = "${var.prefix}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  tags = var.tags
}

resource "azurerm_lb_backend_address_pool" "main" {
  /* resource_group_name = azurerm_resource_group.main.name */
  name            = "${var.prefix}-lb-backend-ap"
  loadbalancer_id = azurerm_lb.main.id
}

resource "azurerm_lb_nat_rule" "main" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "HTTPSAccess"
  protocol                       = "Tcp"
  frontend_port                  = var.application_port
  backend_port                   = var.application_port
  frontend_ip_configuration_name = azurerm_lb.main.frontend_ip_configuration[0].name
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.instance_count
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  ip_configuration_name   = "primary"
  network_interface_id    = element(azurerm_network_interface.main.*.id, count.index)
}


/* 
 Reference to the VM image
 */
data "azurerm_image" "main" {
  name                = var.image_name
  resource_group_name = var.image_ressource_group
}
/* 
 Definition of Virtual machine
 */
resource "azurerm_virtual_machine" "main" {
  count               = var.instance_count
  name                = "${var.prefix}-vm${count.index}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vm_size             = "Standard_B1s"
  /* admin_username      = var.admin_user */

  availability_set_id = azurerm_availability_set.avset.id

  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  storage_image_reference {
    id = data.azurerm_image.main.id
  }

  delete_os_disk_on_termination = true
  storage_os_disk {
    name              = "${var.prefix}-osdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-vm${count.index}"
    admin_username = var.admin_user
    /* admin_password = var.admin_password */
  }
  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = file("~/.ssh/id_rsa.pub")
    }
  }

  tags = var.tags
}

/* 
 Definitions of managed_disk
 */
resource "azurerm_managed_disk" "data" {
  count                = var.instance_count
  name                 = "${var.prefix}-data${count.index}"
  location             = azurerm_resource_group.main.location
  create_option        = "Empty"
  disk_size_gb         = 1
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = var.instance_count
  virtual_machine_id = azurerm_virtual_machine.main[count.index].id
  managed_disk_id    = azurerm_managed_disk.data[count.index].id
  lun                = 0
  caching            = "None"
}
