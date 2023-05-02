resource "digitalocean_loadbalancer" "default" {
  name     = var.loadbalancer_name
  region   = var.region
  vpc_uuid = var.vpc_uuid

  dynamic "forwarding_rule" {
    for_each = var.forwarding_rules
    content {
      entry_protocol   = forwarding_rule.value.entry_protocol
      entry_port       = forwarding_rule.value.entry_port
      target_protocol  = forwarding_rule.value.target_protocol
      target_port      = forwarding_rule.value.target_port
      certificate_name = forwarding_rule.value.certificate_name #forwarding_rule.value.certificate_name
      tls_passthrough  = forwarding_rule.value.tls_passthrough
    }
  }
}
