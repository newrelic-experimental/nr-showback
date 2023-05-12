# terraform config 
terraform {
  required_version = ">= 1.3.1"
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 3.11.0, <4.0.0"
    }
  }
}

provider "newrelic" {
  region = "US" 
}
