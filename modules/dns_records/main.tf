resource "digitalocean_domain" "this" {
  name = var.domain_name
}

resource "digitalocean_domain_record" "this" {
  for_each = { for r in var.records : r.name => r }

  domain = digitalocean_domain.this.name
  type   = each.value.type
  name   = each.value.name
  value  = each.value.value
  ttl    = each.value.ttl
}
