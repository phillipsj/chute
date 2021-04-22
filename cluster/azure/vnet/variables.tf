variable "vnet_name" {
  description = "Name of the vnet to create"
  default     = "acctvnet"
}

variable "resource_group" {
  description = "Default resource group name that the network will be created in."
  type = object({
    name     = string
    location = string
  })
}

variable "address_space" {
  description = "The address space that is used by the virtual network."
  default     = "10.10.0.0/16"
}

# If no values specified, this defaults to Azure DNS
variable "dns_servers" {
  description = "The DNS servers to be used with vNet."
  default     = []
}

variable "subnet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  type        = list(any)
  default     = ["subnet1", "subnet2"]
}

variable "subnet_service_endpoints" {
  description = "A list of the service endpoints for the subnet (e.g. Microsoft.Web)"
  type        = list(any)
  default     = [[], []]
}

variable "tags" {
  description = "The tags to associate with your network and subnets."
  type        = map(any)

  default = {
    tag1 = ""
    tag2 = ""
  }
}