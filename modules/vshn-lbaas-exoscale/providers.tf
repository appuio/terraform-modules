terraform {
  required_version = ">= 1.3.0"
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = "0.62.3"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3"
    }
    cidr = {
      source  = "volcano-coffee-company/cidr"
      version = "0.1.0"
    }
  }
}
