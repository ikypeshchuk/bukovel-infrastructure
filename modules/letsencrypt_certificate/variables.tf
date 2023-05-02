variable "project_domains" {
  type        = list(string)
  description = "A list of domain names for the project"
  default     = []
}
variable "certificate_name" {
  description = "The region for the load balancer"
  type        = string
}
