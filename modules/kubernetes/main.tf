resource "digitalocean_kubernetes_cluster" "production" {
  name     = var.cluster_name
  region   = var.region
  version  = var.do_kubernetes_version
  vpc_uuid = var.vpc_uuid

  node_pool {
    name       = var.node_pool_name
    size       = var.node_size
    auto_scale = true
    min_nodes  = var.min_node_count
    max_nodes  = var.max_node_count
  }
  registry_integration = var.registry_integration
}
