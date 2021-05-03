variable "resource_group_name" {
  description = "Default resource group name that the network will be created in."
  type        = string
}

variable "gallery_name" {
    description = "The name of the shared image gallery."
    type        = string
}

variable "gallery_description" {
    description = "The description of the gallery. Default is set."
    type        = string
    default     = "Shared images for Rancher and RKE base images."
}

variable "tags" {
  description = "The tags to associate with the keyvault"
  type        = map(any)
  default     = {}
}