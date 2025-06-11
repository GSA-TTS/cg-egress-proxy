output "https_proxy" {
  value     = { for name, creds in local.creds : name => creds.https_uri }
  sensitive = true
}

output "http_proxy" {
  value     = { for name, creds in local.creds : name => creds.http_uri }
  sensitive = true
}

output "domain" {
  value = local.domain
}

output "http_port" {
  value = local.common_json.http_port
}

output "https_port" {
  value = local.common_json.https_port
}

output "username" {
  value = { for name, creds in local.creds : name => creds.username }
}

output "password" {
  value     = { for name, creds in local.creds : name => creds.password }
  sensitive = true
}

output "app_id" {
  value = cloudfoundry_app.egress_app.id
}

output "json_credentials" {
  value     = length(local.configuration) == 1 ? local.single_client_json : local.multi_client_json
  sensitive = true
}
