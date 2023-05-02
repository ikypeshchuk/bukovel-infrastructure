resource "digitalocean_domain" "default" {
  count = var.create_domain ? 1 : 0
  name  = var.domain_name
}
resource "time_sleep" "wait" {
  depends_on = [digitalocean_domain.default]

  create_duration = "10s"
}

resource "digitalocean_record" "default" {
  for_each = { for r in var.records : r.name => r }

  domain = var.domain_name
  type   = each.value.type
  name   = each.value.name
  value  = each.value.value
  ttl    = each.value.ttl

  depends_on = [time_sleep.wait]
}
