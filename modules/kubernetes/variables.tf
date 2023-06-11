variable "min_node_count" {
  description = "Minimum number of nodes in the node pool"
  type        = number
}

variable "max_node_count" {
  description = "Maximum number of nodes in the node pool"
  type        = number
}
variable "registry_integration" {
  description = "Enables or disables the DigitalOcean container registry integration for the cluster."
  type        = bool
  default     = false
}

variable "vpc_uuid" {
  description = "The ID of the VPC where the Kubernetes cluster will be located."
  type        = string
  default     = ""
}
variable "region" {
  description = "The DigitalOcean region where the resources will be created"
  type        = string
  default     = "fra1"
}
variable "node_size" {
  description = "The DigitalOcean node size to be use"
  type        = string
}
variable "node_pool_name" {
  description = "The name of the node pool for the Kubernetes cluster"
  type        = string
  default     = "worker-pool"
}

variable "do_kubernetes_version" {
  description = "The Kubernetes version for the DigitalOcean cluster"
  type        = string
  default     = "1.26.3-do.0"
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
  default     = "k8s-cluster"
}
