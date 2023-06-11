variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = false
}

variable "ssh_key_fingerprint" {
  description = "The fingerprint of the SSH key to be used for the local runner"
  type        = string
}

variable "private_ssh_key_path" {
  description = "The local path to the private SSH key for the local runner"
  type        = string
}

variable "github_runner_token" {
  description = "The GitHub runner token for registering the local runner"
  type        = string
  sensitive   = false
}

variable "github_repo_url" {
  description = "The GitHub repository URL where the local runner will be registered"
  type        = string
}

variable "conf" {
  description = "Common Cluster Configuration"
  type        = map(string)
  default = {
    name       = "bukovel"
    enviroment = "dev"
    region     = "fra1"
  }
}

variable "enabled_modules" {
  description = "Map of module names and their enabled status"
  type        = map(bool)
  default = {
    kubernetes                           = false # 1st phase. Enable Kubernetes module 
    dns_records                          = false # 1st phase. Enable DNS records module 
    container_registry                   = true # 1st phase. Enable Container Registry module
    firewall                             = false # 1st phase Enable Firewall module
    vpc                                  = false  # 1st phase, Enable VPC module 
    postgresql                           = false # 2rd phase Enable Kubernetes resources module
    kubernetes_resources                 = false # 3rd phase Enable Kubernetes resources module
    loadbalancer_dns_records             = false # 4rd phase Enable DNS records module
    loadbalancer_letsencrypt_certificate = false # 5rd phase Enable Letsencrypt certificate module
    letsencrypt_certificate              = false # 5rd phase Enable Letsencrypt certificate module
    local_runner                         = true  # 6rd phase Enable Local runner module
  }
}
