terraform {
  required_version = "~> 0.15.0"
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.56"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rke2_rg" {
  name     = var.resource_group_name
  location = var.region
}

resource "azurerm_storage_account" "rke2" {
  name                     = "jprke2eus2st"
  resource_group_name      = azurerm_resource_group.rke2_rg.name
  location                 = azurerm_resource_group.rke2_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "rke2" {
  name                  = "rke2"
  storage_account_name  = azurerm_storage_account.rke2.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "rke2" {
  connection_string = azurerm_storage_account.rke2.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = false
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2018-03-21T00:00:00Z"
  expiry = "2020-03-21T00:00:00Z"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
  }
}

data "azurerm_platform_image" "opensuse" {
  location  = azurerm_resource_group.rke2_rg.location
  publisher = "SUSE"
  offer     = "openSUSE-Leap"
  sku       = "15-2"
}

resource "tls_private_key" "rke2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "rke2_pem" {
  sensitive_content = tls_private_key.rke2.private_key_pem
  filename          = var.private_ssh_key_path
}

module "provider" {
  source = "../../azure/provider"
}

module "vnet" {
  source = "../../azure/vnet"

  resource_group = {
    name     = azurerm_resource_group.rke2_rg.name
    location = azurerm_resource_group.rke2_rg.location
  }
  vnet_name     = var.vnet_name
  address_space = var.address_space

  tags = {
    environment = "RKE2"
  }
}

module "subnet" {
  source = "../../azure/subnet"

  subnet_name         = "${var.cluster_name}-subnet"
  vnet_name           = module.vnet.vnet_name
  resource_group_name = azurerm_resource_group.rke2_rg.name
  address_prefixes = [
  var.subnet_prefix]
}

resource "azurerm_network_security_group" "rke2" {
  name                = "jp-rke2-server-sg"
  location            = azurerm_resource_group.rke2_rg.location
  resource_group_name = azurerm_resource_group.rke2_rg.name

  tags = {
    environment = "RKE2"
  }
}

module "cluster_inbound_rules" {
  source                      = "../../rke2/cluster_inbound_rules"
  resource_group_name         = azurerm_resource_group.rke2_rg.name
  subnet_id                   = module.subnet.subnet_id
  network_security_group_name = azurerm_network_security_group.rke2.name
  network_security_group_id   = azurerm_network_security_group.rke2.id
}

resource "azurerm_public_ip" "rke2_server" {
  name                = "rke2server-pip"
  location            = azurerm_resource_group.rke2_rg.location
  resource_group_name = azurerm_resource_group.rke2_rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = var.server_hostname
}

module "server_cloud_init" {
  source               = "../../rke2/server_cloud_init"
  update_server        = false
  sas_token            = data.azurerm_storage_account_sas.rke2.sas
  storage_account_name = azurerm_storage_account.rke2.name
  container_name       = azurerm_storage_container.rke2.name
}

module "server" {
  source = "../../rke/linux_node"

  resource_group = {
    name     = azurerm_resource_group.rke2_rg.name
    location = azurerm_resource_group.rke2_rg.location
  }

  vm_size   = "Standard_D2as_v4"
  subnet_id = module.subnet.subnet_id

  hostname     = var.server_hostname
  public_ip_id = azurerm_public_ip.rke2_server.id

  admin_ssh_key = {
    username   = "rkeserveradmin"
    public_key = tls_private_key.rke2.public_key_openssh
  }

  image_info = {
    publisher = data.azurerm_platform_image.opensuse.publisher
    offer     = data.azurerm_platform_image.opensuse.offer
    sku       = data.azurerm_platform_image.opensuse.sku
    version   = data.azurerm_platform_image.opensuse.version
  }

  cloud_init_data = module.server_cloud_init.cloud-init-rendered
}

module "agent_cloud_init" {
  source               = "../../rke2/agent_cloud_init"
  sas_token            = data.azurerm_storage_account_sas.rke2.sas
  storage_account_name = azurerm_storage_account.rke2.name
  container_name       = azurerm_storage_container.rke2.name
  rke_server           = var.server_hostname
}

module "agent_one" {
  source = "../../rke/linux_node"

  resource_group = {
    name     = azurerm_resource_group.rke2_rg.name
    location = azurerm_resource_group.rke2_rg.location
  }

  vm_size   = "Standard_D2as_v4"
  subnet_id = module.subnet.subnet_id

  hostname = "jprke2agent1"

  admin_ssh_key = {
    username   = "rkeserveradmin"
    public_key = tls_private_key.rke2.public_key_openssh
  }

  image_info = {
    publisher = data.azurerm_platform_image.opensuse.publisher
    offer     = data.azurerm_platform_image.opensuse.offer
    sku       = data.azurerm_platform_image.opensuse.sku
    version   = data.azurerm_platform_image.opensuse.version
  }

  cloud_init_data = module.agent_cloud_init.cloud-init-rendered
}