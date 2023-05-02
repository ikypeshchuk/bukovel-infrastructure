variable "kubeconfig_filename" {
  description = "The path to the kubeconfig file"
  type        = string
}

variable "cluster_dependency" {
  description = "A dependency reference to the Kubernetes cluster resource"
  type        = any
}
