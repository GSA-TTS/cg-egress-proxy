terraform {
  required_version = "1.17.2"
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "1.19.0"
    }
  }
}
