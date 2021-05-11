variable "resource_group_name" {
  description = "The resource group name of the the security group."
}

variable "network_security_group_name" {
  description = "The network security group name to associate the rules."
}

variable "network_security_group_id" {
  description = "The network security group id to associate the rules."
}

variable "subnet_id" {
  description = "The id of the subnet."
}