locals {
  # Yields something like: orgname-spacename-name.apps.internal, limited to the last 63 characters
  default_route_host = "${replace(var.cf_org_name, ".", "-")}-${replace(var.cf_egress_space.name, ".", "-")}-${var.name}"
  egress_host        = replace(lower(substr(coalesce(var.route_host, local.default_route_host), -63, -1)), "/^[^a-z]*/", "")
}

resource "random_password" "client_password" {
  for_each = var.client_configuration
  length   = 16
  special  = false
}

resource "random_uuid" "random_username" {}
resource "random_password" "random_password" {
  length  = 16
  special = false
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.module}/proxy"
  output_path = "${path.module}/dist/src.zip"
}

locals {
  configuration = { for name, config in var.client_configuration : name => merge(config, {
    safe_name = replace(lower(name), "/[^a-z0-9_]+/", "_")
    user_name = replace(name, ":", "")
  }) }
  environment_credentials = [for name, config in local.configuration : {
    "PROXY_USERNAME_${config.safe_name}" = config.user_name
    "PROXY_PASSWORD_${config.safe_name}" = random_password.client_password[name].result
  }]
}

resource "cloudfoundry_app" "egress_app" {
  name       = var.name
  space_name = var.cf_egress_space.name
  org_name   = var.cf_org_name

  path             = data.archive_file.src.output_path
  source_code_hash = data.archive_file.src.output_base64sha256
  buildpacks       = ["binary_buildpack"]
  command          = "./run.sh ./caddy run --config Caddyfile"
  memory           = var.egress_memory
  instances        = var.instances
  strategy         = "rolling"
  enable_ssh       = var.enable_ssh

  routes = [{
    route = cloudfoundry_route.egress_route.url
  }]

  environment = merge(
    {
      CADDY_LOG_LEVEL       = "INFO"
      PROXY_RANDOM_USERNAME = random_uuid.random_username.result
      PROXY_RANDOM_PASSWORD = random_password.random_password.result
      CONFIG_CONTENT = templatefile("${path.module}/Caddyfile.tftpl", {
        configuration = values(local.configuration)
      })
    },
    local.environment_credentials...
  )
}

data "cloudfoundry_domain" "internal_domain" {
  name = "apps.internal"
}
resource "cloudfoundry_route" "egress_route" {
  domain = data.cloudfoundry_domain.internal_domain.id
  space  = var.cf_egress_space.id
  host   = local.egress_host

  lifecycle {
    ignore_changes = [domain]
  }
}

locals {
  domain = cloudfoundry_route.egress_route.url
  creds = { for name, config in local.configuration : name => {
    https_uri = "https://${config.user_name}:${random_password.client_password[name].result}@${local.domain}:61443"
    http_uri  = "http://${config.user_name}:${random_password.client_password[name].result}@${local.domain}:8080"
    username  = config.user_name
    password  = random_password.client_password[name].result
  } }
  common_json = {
    domain     = local.domain
    https_port = 61443
    http_port  = 8080
  }
  single_client_json = jsonencode(merge(local.common_json, values(local.creds)[0]))
  multi_client_json  = jsonencode(merge(local.common_json, { credentials = local.creds }))
}
