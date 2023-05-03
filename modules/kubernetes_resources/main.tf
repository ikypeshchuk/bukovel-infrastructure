locals {
  kubeconfig_exists = fileexists("kubeconfig.yaml")
}
resource "null_resource" "wait_for_credentials" {
  provisioner "local-exec" {
    command = "${path.module}/wait_for_credentials.sh ${var.kubeconfig_filename} 900"
  }
  depends_on = [var.cluster_dependency]
}
# data "digitalocean_loadbalancer" "lb_k8s" {
#   depends_on = [time_sleep.wait_for_lb]
#   name       = "ingress-nginx-lb"
# }

# resource "time_sleep" "wait_for_lb" {
#   depends_on      = [kubernetes_manifest.ingress_nginx_lb]
#   create_duration = "5m" # Adjust the duration as needed
# }

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
resource "null_resource" "wait_for_ip" {
  depends_on = [kubernetes_manifest.ingress_nginx_lb]

  provisioner "local-exec" {
    command = <<-EOT
      KUBECONFIG_CONTEXT=$(yq e '.current-context' kubeconfig.yaml)
      KUBECONFIG_CLUSTER=$(yq e ".contexts[] | select(.name == \"$KUBECONFIG_CONTEXT\") | .context.cluster" kubeconfig.yaml)
      KUBECONFIG_SERVER=$(yq e ".clusters[] | select(.name == \"$KUBECONFIG_CLUSTER\") | .cluster.server" kubeconfig.yaml)

      until IP=$(kubectl --server "$KUBECONFIG_SERVER" --kubeconfig kubeconfig.yaml get service ingress-nginx-lb -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}') && echo $IP | grep -Eo '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; do
        echo "Waiting for LoadBalancer IP..."
        sleep 10
      done

      echo "lb_ip=$IP" > ${path.module}/lb_ip.env
    EOT
  }
}






