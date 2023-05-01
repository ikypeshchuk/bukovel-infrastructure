resource "digitalocean_database_backup" "postgres" {
  cluster_id = var.cluster_id
  hour       = var.backup_hour
}
