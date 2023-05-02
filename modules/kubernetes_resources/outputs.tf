# output "ingress_nginx_lb_ip" {
#   value = kubernetes_manifest.ingress_nginx_lb[0].status.loadBalancer.ingress[0].ip
# }


# output "ingress_nginx_lb_ip" {
#   description = "Ingress Nginx LoadBalancer IP"
#   value       = length(kubernetes_manifest.ingress_nginx_lb) > 0 ? kubernetes_manifest.ingress_nginx_lb[0].status.loadBalancer.ingress[0].ip : null
# }
