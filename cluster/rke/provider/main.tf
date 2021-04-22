terraform {
  required_version = "~> 0.15.0"
  required_providers {
    rancher2 = {
      source  = "rancher/rke"
      version = "~> 1.2"
    }
  }
}