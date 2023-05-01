variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "region" {
  description = "The region of the VPC"
  type        = string
}

variable "ip_range" {
  description = "The IP range for the VPC"
  type        = string
}
