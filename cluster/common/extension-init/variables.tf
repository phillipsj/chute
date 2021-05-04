variable "virtual_machine_id" {
  description = "The ID of the virtual machine to attach the extension."
  type        = string
}

variable "dokcer_cmd" {
  description = "The dokcer command to execute to run Rancher."
  type        = string
}

variable "tags" {
  type    = map(any)
  default = {}
}