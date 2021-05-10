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

resource "azurerm_resource_group" "rancher_rg" {
  name     = var.resource_group_name
  location = var.region
}

data "azurerm_platform_image" "opensuse" {
  location  = azurerm_resource_group.rancher_rg.location
  publisher = "SUSE"
  offer     = "openSUSE-Leap"
  sku       = "15-2"
}

resource "tls_private_key" "rancher" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "rancher_pem" {
  sensitive_content = tls_private_key.rancher.private_key_pem
  filename          = var.private_ssh_key_path
}

module "provider" {
  source = "../../azure/provider"
}

module "vnet" {
  source = "../../azure/vnet"

  resource_group = {
    name     = azurerm_resource_group.rancher_rg.name
    location = azurerm_resource_group.rancher_rg.location
  }
  vnet_name     = var.vnet_name
  address_space = var.address_space

  tags = {
    environment = "rancher-standalone"
  }
}

module "subnet" {
  source = "../../azure/subnet"

  subnet_name         = "${var.cluster_name}-subnet"
  vnet_name           = module.vnet.vnet_name
  resource_group_name = azurerm_resource_group.rancher_rg.name
  address_prefixes = [
  var.subnet_prefix]
}

resource "azurerm_network_security_group" "rancher" {
  name                = "rancher-sg"
  location            = azurerm_resource_group.rancher_rg.location
  resource_group_name = azurerm_resource_group.rancher_rg.name

  tags = {
    environment = "Rancher"
  }
}

module "node_inbound" {
  source = "../../rancher/node_inbound_rules"

  resource_group_name         = azurerm_resource_group.rancher_rg.name
  network_security_group_name = azurerm_network_security_group.rancher.name
}

module "node_outbound" {
  source = "../../rancher/node_outbound_rules"

  resource_group_name         = azurerm_resource_group.rancher_rg.name
  network_security_group_name = azurerm_network_security_group.rancher.name
}

resource "azurerm_public_ip" "rancher" {
  name                = "rancher-pip"
  location            = azurerm_resource_group.rancher_rg.location
  resource_group_name = azurerm_resource_group.rancher_rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = var.hostname
}