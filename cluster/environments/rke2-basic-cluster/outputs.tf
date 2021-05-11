output "private_ip" {
  description = "The assigned private ip."
  value       = module.server.private_ip
}

output "public_ip" {
  description = "The assigned public ip."
  value       = module.server.public_ip
}

output "fqdn" {
  description = "The fully qualified domain name."
  value       = azurerm_public_ip.rke2_server.fqdn
}