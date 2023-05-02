
resource "digitalocean_vpc" "default" {
  name     = var.vpc_name
  region   = var.region
  ip_range = var.ip_range
  timeouts {
    delete = "30m"
  }
}
