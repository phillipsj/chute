terraform {
  required_version = "~> 0.15.0"
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "~> 1.13"
    }
  }
}