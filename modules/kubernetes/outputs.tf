output "k8s_cluster_id" {
  value       = digitalocean_kubernetes_cluster.production.id
  description = "The ID of the VPC"
}

output "node_pool_droplet_ids" {
  value = [
    for node in digitalocean_kubernetes_cluster.production.node_pool[0].nodes : node.droplet_id
  ]
  description = "The droplet IDs of the Kubernetes cluster node pool"
}
output "kubeconfig" {
  value       = digitalocean_kubernetes_cluster.production.kube_config.0.raw_config
  description = "Kubeconfig file for the Kubernetes cluster"
  sensitive   = true
}
output "cluster_endpoint" {
  value = digitalocean_kubernetes_cluster.production.endpoint
}

output "cluster_ca_certificate" {
  value = digitalocean_kubernetes_cluster.production.kube_config.0.cluster_ca_certificate
}

output "kubeconfig_token" {
  value = digitalocean_kubernetes_cluster.production.kube_config.0.token
}
output "kubeconfig_raw" {
  description = "The raw Kubernetes config to be used by kubectl and other compatible tools."
  value = digitalocean_kubernetes_cluster.production.kube_config.0.raw_config
  sensitive   = true
}
