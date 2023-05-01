output "kubeconfig" {
  value       = module.kubernetes.kubeconfig
  description = "Kubeconfig file for the Kubernetes cluster"
  sensitive   = true
}
