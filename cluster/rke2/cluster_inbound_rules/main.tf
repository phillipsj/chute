module "etcd_inbound_rules" {
  source = "../../rke2/etcd_inbound_rules"

  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

module "ssh_inbound_rules" {
  source = "../../common/ssh_inbound_rules"

  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

module "http_inbound_rules" {
  source = "../../common/http_inbound_rules"

  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

module "k8s_inbound_rules" {
  source = "../../rke2/k8s_inbound_rules"

  resource_group_name         = var.resource_group_name
  network_security_group_name = var.network_security_group_name
}

resource "azurerm_subnet_network_security_group_association" "rke_security_group" {
  subnet_id                 = var.subnet_id
  network_security_group_id = var.network_security_group_id
}