variable "domain_name" {
  type = string
}
variable "create_domain" {
  description = "Whether to create the domain or use an existing one"
  type        = bool
  default     = true
}

variable "records" {
  type = list(object({
    name  = string
    type  = string
    value = string
    ttl   = number
  }))
}
