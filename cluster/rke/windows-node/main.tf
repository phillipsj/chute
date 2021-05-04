resource "azurerm_subnet_network_security_group_association" "rke_windows_node" {
  subnet_id                 = var.subnet_id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_network_interface" "rke_windows_node" {
  name                = "${var.hostname}-nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "Primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "rke_windows_node" {
  name                = var.hostname
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  size                = var.vm_size
  admin_username      = var.admin_creds.username
  admin_password      = var.admin_creds.password
  network_interface_ids = [
    azurerm_network_interface.rke_windows_node.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = var.image_id

  dynamic "source_image_reference" {
    for_each = var.image_id == null ? list(1) : []
    content {
      publisher = var.image_info.publisher
      offer     = var.image_info.offer
      sku       = var.image_info.sku
      version   = var.image_info.version
    }
  }

  tags = var.tags
}