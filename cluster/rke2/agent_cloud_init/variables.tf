variable "update_server" {
  description = "Determines if packages should be updated on first boot. Defaults to true."
  type        = bool
  default     = true
}

variable "token" {
  description = "RKE2 Token"
  type        = string
}

variable "rke_server" {
  description = "RKE2 Server URL."
  type        = string
}