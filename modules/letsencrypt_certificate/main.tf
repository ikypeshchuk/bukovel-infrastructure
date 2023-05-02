resource "digitalocean_certificate" "cert" {
  name    = var.certificate_name
  type    = "lets_encrypt"
  domains = var.project_domains
}
