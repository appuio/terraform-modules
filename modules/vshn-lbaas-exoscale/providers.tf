terraform {
  required_version = ">= 1.3.0"
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "0.78.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3"
    }
  }
}
