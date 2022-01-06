terraform {
  required_version = ">= 0.14"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = ">= 0.30"
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
