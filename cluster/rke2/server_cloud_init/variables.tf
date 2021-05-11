variable "update_server" {
  description = "Determines if packages should be updated on first boot. Defaults to true."
  type        = bool
  default     = true
}

variable "storage_account_name" {
  description = "The storage account to upload the token."
  type        = string
}

variable "sas_token" {
  description = "The SAS token for the storage account."
  type        = string
}

variable "container_name" {
  description = "Azure Blob storage container that has the token."
  type        = string
}