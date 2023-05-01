

variable "firewall_name" {
  description = "The name of the firewall"
  type        = string
}

variable "inbound_rules" {
  description = "List of inbound rules for the firewall"
  type = list(object({
    protocol         = string
    port_range       = string
    source_addresses = list(string)
  }))
}

variable "kubernetes_droplet_ids" {
  description = "The droplet IDs of the Kubernetes cluster"
  type        = list(number)
}
