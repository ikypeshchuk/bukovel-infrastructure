variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "enabled_modules" {
  description = "Map of module names and their enabled status"
  type        = map(bool)
  default = {
    kubernetes                           = true # 1st phase. Enable Kubernetes module 
    dns_records                          = true # 1st phase. Enable DNS records module 
    container_registry                   = true # 1st phase. Enable Container Registry module
    firewall                             = true # 1st phase Enable Firewall module
    vpc                                  = true # 1st phase, Enable VPC module 
    kubernetes_resources                 = true  # 2rd phase Enable Kubernetes resources module
    loadbalancer_dns_records             = true # 3rd phase Enable DNS records module 
    loadbalancer_letsencrypt_certificate = false # 4rd phase Enable Letsencrypt certificate module 
    letsencrypt_certificate              = false # 4rd phase Enable Letsencrypt certificate module 
  }
}
