variable "update_server" {
  description = "Determines if packages should be updated on first boot. Defaults to true."
  type        = bool
  default     = true
}

variable "docker_cmd" {
  description = "The docker command to execute to run Rancher."
  type        = string
}