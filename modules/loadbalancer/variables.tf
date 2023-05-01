variable "loadbalancer_name" {
  description = "The name of the load balancer"
  type        = string
}

variable "region" {
  description = "The region for the load balancer"
  type        = string
}

variable "forwarding_rules" {
  description = "List of forwarding rules for the load balancer"
  type = list(object({
    entry_protocol  = string
    entry_port      = number
    target_protocol = string
    target_port     = number
    certificate_id  = string
    tls_passthrough = bool
  }))
}

variable "vpc_uuid" {
  description = "The ID of the VPC where the Kubernetes cluster will be located."
  type        = string
  default     = ""
}
