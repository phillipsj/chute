data "azurerm_resource_group" "shared_gallery" {
  name = var.resource_group_name
}

resource "azurerm_shared_image_gallery" "shared_gallery" {
  name                = var.gallery_name
  resource_group_name = azurerm_resource_group.shared_gallery.name
  location            = azurerm_resource_group.shared_gallery.location
  description         = var.gallery_description
  tags                = var.tags
}
