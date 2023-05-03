
output "load_balancer_ip" {
  value     = trimspace(try(length(file("${path.module}/lb_ip.env")) > 0 ? split("=", file("${path.module}/lb_ip.env"))[1] : "", ""))
  sensitive = false
}