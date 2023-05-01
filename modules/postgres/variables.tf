variable "db_name" {
  description = "The name of the PostgreSQL database cluster"
  type        = string
}

variable "db_version" {
  description = "The version of the PostgreSQL database"
  type        = string
}

variable "db_size" {
  description = "The size of the PostgreSQL database"
  type        = string
}

variable "db_region" {
  description = "The region of the PostgreSQL database"
  type        = string
}

variable "db_node_count" {
  description = "The number of nodes in the PostgreSQL database cluster"
  type        = number
}

variable "vpc_uuid" {
  description = "The ID of the VPC where the Kubernetes cluster will be located."
  type        = string
  default     = ""
}
