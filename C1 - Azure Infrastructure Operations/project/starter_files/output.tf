output "vm_fqdn" {
  value = azurerm_public_ip.pip.fqdn
}

output "vm_ip_address" {
  value = azurerm_public_ip.pip.ip_address
}