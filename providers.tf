terraform {
  required_version = "1.16.4"
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "1.18.0"
    }
  }
}
