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

resource "azurerm_network_security_group" "rke2_server" {
  name                = "rke2-server-sg"
  location            = azurerm_resource_group.rke2_rg.location
  resource_group_name = azurerm_resource_group.rke2_rg.name

  tags = {
    environment = "RKE2"
  }
}

module "server_inbound_rules" {
  source = "../../rke2/server_inbound_rules"

  resource_group_name         = azurerm_resource_group.rke2_rg.name
  network_security_group_name = azurerm_network_security_group.rke2_server.name
}

module "server_agent_inbound_rules" {
  source = "../../rke2/server_agent_inbound_rules"

  resource_group_name         = azurerm_resource_group.rke2_rg.name
  network_security_group_name = azurerm_network_security_group.rke2_server.name
}

resource "azurerm_network_security_group" "rke2_agent" {
  name                = "rke2-agent-sg"
  location            = azurerm_resource_group.rke2_rg.location
  resource_group_name = azurerm_resource_group.rke2_rg.name

  tags = {
    environment = "RKE2"
  }
}

module "agent_inbound_rules" {
  source = "../../rke2/agent_inbound_rules"

  resource_group_name         = azurerm_resource_group.rke2_rg.name
  network_security_group_name = azurerm_network_security_group.rke2_agent.name
}

module "agent_server_inbound_rules" {
  source = "../../rke2/server_agent_inbound_rules"

  resource_group_name         = azurerm_resource_group.rke2_rg.name
  network_security_group_name = azurerm_network_security_group.rke2_agent.name
}

resource "azurerm_public_ip" "rke2_server" {
  name                = "rke2-pip"
  location            = azurerm_resource_group.rke2_rg.location
  resource_group_name = azurerm_resource_group.rke2_rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = var.server_hostname
}

module "server_cloud_init" {
  source = "../../rke2/server_cloud_init"
}

module "server" {
  source = "../../rke/linux-node"

  resource_group = {
    name     = azurerm_resource_group.rke2_rg.name
    location = azurerm_resource_group.rke2_rg.location
  }
  network_security_group_id = azurerm_network_security_group.rke2_server.id
  vm_size                   = "Standard_D2as_v4"
  subnet_id                 = module.subnet.subnet_id

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
  source     = "../../rke2/agent_cloud_init"
  token      = ""
  rke_server = ""
}

module "agent_one" {
  source = "../../rke/linux-node"

  resource_group = {
    name     = azurerm_resource_group.rke2_rg.name
    location = azurerm_resource_group.rke2_rg.location
  }
  network_security_group_id = azurerm_network_security_group.rke2_agent.id
  vm_size                   = "Standard_D2as_v4"
  subnet_id                 = module.subnet.subnet_id

  hostname     = "rke2agent1"
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

  cloud_init_data = module.agent_cloud_init.cloud-init-rendered
}