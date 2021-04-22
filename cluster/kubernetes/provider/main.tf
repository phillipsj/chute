terraform {
  required_version = "~> 0.15.0"
  required_providers {
    helm = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.1"
    }
  }
}