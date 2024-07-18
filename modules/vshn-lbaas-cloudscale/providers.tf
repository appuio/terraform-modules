terraform {
  required_version = ">= 1.3.0"
  required_providers {
    cloudscale = {
      source  = "cloudscale-ch/cloudscale"
      version = ">= 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3"
    }
  }
}
