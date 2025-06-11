output "https_proxy" {
  value     = { for name, creds in local.creds : name => creds.https_proxy }
  sensitive = true
}

output "http_proxy" {
  value     = { for name, creds in local.creds : name => creds.http_proxy }
  sensitive = true
}

output "domain" {
  value = local.domain
}

output "http_port" {
  value = local.http_port
}

output "https_port" {
  value = local.https_port
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
  value = jsonencode({
    "credentials" = local.creds
    "domain"      = local.domain
    "https_port"  = local.https_port
    "http_port"   = local.http_port
  })
  sensitive = true
}
