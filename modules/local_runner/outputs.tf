output "local_runner_ip" {
  description = "The IPv4 address of the local runner droplet"
  value       = digitalocean_droplet.local_runner.ipv4_address
}
