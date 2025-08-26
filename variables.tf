variable "cf_org_name" {
  type        = string
  description = "cloud.gov organization name"
}

variable "cf_egress_space" {
  type = object({
    id   = string
    name = string
  })
  description = "cloud.gov space egress"
}

variable "name" {
  type        = string
  description = "name of the egress proxy application"
}

variable "route_host" {
  type        = string
  default     = null
  description = "Hostname to access the egress proxy on apps.internal domain (optional)"
}

variable "client_configuration" {
  type = map(object({
    # See the upstream documentation for possible acl strings:
    #   https://github.com/caddyserver/forwardproxy/blob/master/README.md#caddyfile-syntax-server-configuration
    allowlist = optional(set(string), [])
    denylist  = optional(set(string), [])
    ports     = optional(set(number), [443])
  }))
  description = "Configuration map {client_name => config}"

  validation {
    condition     = length(var.client_configuration) == 1 || var.authentication
    error_message = "client_configuration only supports one entry when authentication is off"
  }
}

variable "enable_ssh" {
  type        = bool
  default     = false
  description = "Whether to allow ssh into the egress app"
}

variable "authentication" {
  type        = bool
  default     = true
  description = "Set to false to allow connections without proxy auth"
}

variable "egress_memory" {
  type        = string
  default     = "64M"
  description = "Memory to allocate to egress proxy app, including unit"
}

variable "instances" {
  type        = number
  default     = 2
  description = "the number of instances of the HTTPS proxy application to run (default: 2)"
}
