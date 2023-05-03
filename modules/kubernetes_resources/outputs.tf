
output "k8s_lb_ip" {
  value = data.digitalocean_loadbalancer.lb_k8s.ip
}
