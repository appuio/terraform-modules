terraform {
  required_version = ">= 0.14"
  experiments      = [module_variable_optional_attrs]
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 2.1"
    }
    gitfile = {
      source  = "igal-s/gitfile"
      version = "1.0.0"
    }
  }
}
