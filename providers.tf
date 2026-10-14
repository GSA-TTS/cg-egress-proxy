terraform {
  required_version = "1.16.6"
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "1.18.0"
    }
  }
}
