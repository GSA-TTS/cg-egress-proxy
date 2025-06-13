mock_provider "cloudfoundry" {
  mock_data "cloudfoundry_domain" {
    defaults = {
      id = "682327e2-9beb-4a17-ab0c-64f4b6a96a39"
    }
  }
  mock_resource "cloudfoundry_app" {
    defaults = {
      id = "2ccdc746-e68e-4ffa-9417-544966983719"
    }
  }
}

variables {
  cf_org_name = "gsa-tts-devtools-prototyping"
  cf_egress_space = {
    id   = "5178d8f5-d19a-4782-ad07-467822480c68"
    name = "terraform-cloudgov-ci-tests-egress"
  }
  name = "terraform-egress-app"
  client_configuration = {
    "feedabee" = {
      allowlist = ["raw.githubusercontent.com:443"]
    }
  }
}

run "test_proxy_creation" {
  assert {
    condition     = output.https_proxy == { for name, _ in var.client_configuration : name => "https://${output.username[name]}:${output.password[name]}@${output.domain}:61443" }
    error_message = "HTTPS_PROXY output must match the correct form, got ${nonsensitive(output.https_proxy["feedabee"])}"
  }

  assert {
    condition     = output.domain == cloudfoundry_route.egress_route.url
    error_message = "Output domain must match the route url"
  }

  assert {
    condition     = output.username == { for name, config in local.configuration : name => config.user_name }
    error_message = "Output username must come from the random_uuid resource"
  }

  assert {
    condition     = output.password == { for name, _ in var.client_configuration : name => random_password.client_password[name].result }
    error_message = "Output password must come from the random_password resource"
  }

  assert {
    condition     = output.app_id == cloudfoundry_app.egress_app.id
    error_message = "Output app_id is the egress_app's ID"
  }

  assert {
    condition     = output.https_port == 61443
    error_message = "https_port only supports 61443 internal https listener"
  }

  assert {
    condition     = output.http_port == 8080
    error_message = "http_port reports port 8080 for plaintext"
  }

}

run "test_specific_hostname_bug" {
  variables {
    cf_org_name = "gsa-tts-devtools-prototyping"
    cf_egress_space = {
      id   = "169c6e21-2513-43f7-bbff-80cc5e456882"
      name = "rca-tfm-stage-egress"
    }
    name = "egress-proxy-staging"
  }
  assert {
    condition     = can(regex("[a-z]", substr(local.egress_host, 0, 1)))
    error_message = "proxy domain must start with an alpha character"
  }
}

run "test_custom_hostname_is_trimmed" {
  variables {
    route_host = "-3host-name"
  }
  assert {
    condition     = local.egress_host == "host-name"
    error_message = "proxy domain is stripped of any non-alpha characters"
  }
}
