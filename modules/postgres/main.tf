
resource "digitalocean_database_cluster" "postgres" {
  name                 = var.db_name
  engine               = "pg"
  version              = var.db_version
  size                 = var.db_size
  region               = var.db_region
  node_count           = var.db_node_count
  private_network_uuid = var.vpc_uuid
}
