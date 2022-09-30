terraform {
  required_version = ">= 1.3.0"
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
