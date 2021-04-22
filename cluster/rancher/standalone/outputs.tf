output "private_ip" {
  description = "The assigned private ip."
  value       = azurerm_linux_virtual_machine.rancher.private_ip_address
}

output "public_ip" {
  description = "The assigned public ip."
  value       = azurerm_linux_virtual_machine.rancher.public_ip_address
}
