resource "digitalocean_container_registry" "default" {
  name                   = var.registry_name
  region                 = var.region
  subscription_tier_slug = var.subscription_tier
}
