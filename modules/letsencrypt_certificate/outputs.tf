output "cert_name" {
  value       = digitalocean_certificate.cert.name
  description = "The ID of the created Let's Encrypt certificate"
}
output "subdomain" {
  value       = split(".", var.project_domains[0])[0]
  description = "The subdomain extracted from the project_domains variable"
}
