variable "hostname" {
  description = "The hostname to use for the Public IP domain label and virtual machine."
  type        = string
}

variable "cloud_init_data" {
  description = "The cloud-init file to use."
  type        = string
}

variable "admin_ssh_key" {
  description = "The ssh key and the user to assign the key for access to the server."
  type = object({
    username   = string
    public_key = string
  })
}

variable "vm_size" {
  description = "The virtual machine size, default is a Standard_A1_v2."
  type        = string
  default     = "Standard_A1_v2"
}

variable "subnet_id" {
  description = "Id of the subnet that the Rancher server will be located."
  type        = string
}

variable "network_security_group_id" {
  description = "Id of the network security group that the Rancher server will use."
  type        = string
}

variable "image_info" {
  description = "The information for the image to use for creating the virtual machine."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "update_server" {
  description = "Determines if packages should be updated on first boot. Defaults to true."
  type        = bool
  default     = true
}

variable "resource_group" {
  description = "Default resource group name that the network will be created in."
  type = object({
    name     = string
    location = string
  })
}

variable "public_ip_id" {
  type = string
}