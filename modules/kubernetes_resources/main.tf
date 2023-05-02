locals {
  kubeconfig_exists = true
}
resource "null_resource" "wait_for_credentials" {
  provisioner "local-exec" {
    command = "${path.module}/wait_for_credentials.sh ${var.kubeconfig_filename} 900"
  }
  depends_on = [var.cluster_dependency]
}
resource "kubernetes_manifest" "ingress_nginx_lb" {
  depends_on = [null_resource.wait_for_credentials]
  provider   = kubernetes
  manifest = {
    "apiVersion" = "v1"
    "kind"       = "Service"
    "metadata" = {
      "name"      = "ingress-nginx-lb"
      "namespace" = "default"
      "annotations" = {
        "service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol" = "true"
        "service.beta.kubernetes.io/do-loadbalancer-tags"                  = "lb-k8s,ingress-nginx-lb"
        "service.beta.kubernetes.io/do-loadbalancer-name"                  = "ingress-nginx-lb"
      }
    }
    "spec" = {
      "selector" = {
        "app.kubernetes.io/name" = "ingress-nginx"
      }
      "ports" = [
        {
          "name"       = "http"
          "port"       = 80
          "targetPort" = "http"
        },
        {
          "name"       = "https"
          "port"       = 443
          "targetPort" = "https"
        },
      ]
      "type" = "LoadBalancer"
    }
  }

  count = local.kubeconfig_exists ? 1 : 0
  timeouts {
    create = "10m"
    update = "10m"
    delete = "30s"
  }
}



