output "registry_hostname" {
  value       = digitalocean_container_registry.default.server_url
  description = "The hostname of the container registry"
}
