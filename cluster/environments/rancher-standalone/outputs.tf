output "private_ip" {
  description = "The assigned private ip."
  value       = module.standalone.private_ip
}

output "public_ip" {
  description = "The assigned public ip."
  value       = module.standalone.public_ip
}

output "fqdn" {
  description = "The fully qualified domain name."
  value       = azurerm_public_ip.rancher.fqdn
}