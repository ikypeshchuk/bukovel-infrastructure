variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "enabled_modules" {
  description = "Map of module names and their enabled status"
  type        = map(bool)
  default = {
    kubernetes                           = true
    dns_records                          = true
    container_registry                   = true
    kubernetes_resources                 = true
    vpc                                  = true
    loadbalancer_letsencrypt_certificate = false
    loadbalancer_dns_records             = true
    firewall                             = false
    letsencrypt_certificate              = false
  }
}
