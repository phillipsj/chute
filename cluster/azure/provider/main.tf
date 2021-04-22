terraform {
  required_version = "~> 0.15.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.4"
    }
  }
}

# common modules
module "common-provider" {
  source = "../../common/provider"
}