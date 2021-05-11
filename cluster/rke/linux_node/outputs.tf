output "private_ip" {
  description = "The assigned private ip."
  value       = azurerm_linux_virtual_machine.rke_linux_node.private_ip_address
}

output "public_ip" {
  description = "The assigned public ip."
  value       = azurerm_linux_virtual_machine.rke_linux_node.public_ip_address
}

output "id" {
  description = "The ID of the virtual machine."
  value       = azurerm_linux_virtual_machine.rke_linux_node.id
}