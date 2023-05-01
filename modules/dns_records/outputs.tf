output "cert_id" {
  value       = digitalocean_certificate.cert.id
  description = "The ID of the created Let's Encrypt certificate"
}
