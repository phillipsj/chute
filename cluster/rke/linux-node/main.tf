resource "azurerm_subnet_network_security_group_association" "rke_linux_node" {
  subnet_id                 = var.subnet_id
  network_security_group_id = var.network_security_group_id
}

resource "azurerm_network_interface" "rke_linux_node" {
  name                = "${var.hostname}-nic"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  ip_configuration {
    name                          = "Primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id
  }
}

resource "azurerm_linux_virtual_machine" "rke_linux_node" {
  name                = var.hostname
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  size                = var.vm_size
  admin_username      = var.admin_ssh_key.username
  custom_data         = var.cloud_init_data
  computer_name       = var.hostname

  network_interface_ids = [
    azurerm_network_interface.rke_linux_node.id,
  ]

  admin_ssh_key {
    username   = var.admin_ssh_key.username
    public_key = var.admin_ssh_key.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {

    offer     = var.image_info.offer
    publisher = var.image_info.publisher
    sku       = var.image_info.sku
    version   = var.image_info.version
  }
}