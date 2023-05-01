

resource "digitalocean_firewall" "k8s_firewall" {
  name = var.firewall_name

  droplet_ids = var.kubernetes_droplet_ids

  dynamic "inbound_rule" {
    for_each = var.inbound_rules
    content {
      protocol         = inbound_rule.value.protocol
      port_range       = inbound_rule.value.port_range
      source_addresses = inbound_rule.value.source_addresses
    }
  }
}
