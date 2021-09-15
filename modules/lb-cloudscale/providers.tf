terraform {
  required_version = ">= 0.14"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    cloudscale = {
      source  = "cloudscale-ch/cloudscale"
      version = ">= 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.3"
    }
    gitfile = {
      source  = "igal-s/gitfile"
      version = "1.0.0"
    }
  }
}
