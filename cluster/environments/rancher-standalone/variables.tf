variable "rancher_version_tag" {
  description = "The rancher version to use. Defaults to 'latest'."

  type    = string
  default = "latest"
}

variable "cluster_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "region" {
  type    = string
  default = "East US"
}

variable "hostname" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "private_ssh_key_path" {
  type    = string
  default = "./rancher.pem"
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.10.0.0/16"
}

variable "subnet_prefix" {
  description = "The address prefix to use for the subnet."
  default     = "10.10.1.0/24"
}
