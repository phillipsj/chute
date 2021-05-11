output "private_ip" {
  description = "The assigned private ip."
  value       = azurerm_windows_virtual_machine.rke_windows_node.private_ip_address
}

output "public_ip" {
  description = "The assigned public ip."
  value       = azurerm_windows_virtual_machine.rke_windows_node.public_ip_address
}

output "id" {
  description = "The ID of the virtual machine."
  value       = azurerm_windows_virtual_machine.rke_windows_node.ID
}