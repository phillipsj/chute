output "gallery_name" {
  description = "The name of the shared image gallery."
  value       = azurerm_shared_image_gallery.shared_gallery.name
}