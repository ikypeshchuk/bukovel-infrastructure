locals {
  kubeconfig_exists = fileexists("kubeconfig.yaml")
}
resource "null_resource" "wait_for_credentials" {
  provisioner "local-exec" {
    command = "${path.module}/wait_for_credentials.sh ${var.kubeconfig_filename} 900"
  }
  depends_on = [var.cluster_dependency]
}

resource "random_id" "trigger" {
  byte_length = 8
}

resource "null_resource" "apply_manifests" {
  triggers = {
    trigger_id = random_id.trigger.hex
  }
  depends_on = [null_resource.wait_for_credentials]

  provisioner "local-exec" {
    command = <<-EOT
      KUBECONFIG_CONTEXT=$(yq e '.current-context' kubeconfig.yaml)
      KUBECONFIG_CLUSTER=$(yq e ".contexts[] | select(.name == \"$KUBECONFIG_CONTEXT\") | .context.cluster" kubeconfig.yaml)
      KUBECONFIG_SERVER=$(yq e ".clusters[] | select(.name == \"$KUBECONFIG_CLUSTER\") | .cluster.server" kubeconfig.yaml)
      kubectl --server "$KUBECONFIG_SERVER" --kubeconfig kubeconfig.yaml apply -f ${path.module}/manifests/ingress-nginx.yaml
    EOT
  }
}

resource "null_resource" "delete_manifests" {
  depends_on = [null_resource.apply_manifests]

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
  KUBECONFIG_CONTEXT=$(yq e '.current-context' kubeconfig.yaml)
  KUBECONFIG_CLUSTER=$(yq e ".contexts[] | select(.name == \"$KUBECONFIG_CONTEXT\") | .context.cluster" kubeconfig.yaml)
  KUBECONFIG_SERVER=$(yq e ".clusters[] | select(.name == \"$KUBECONFIG_CLUSTER\") | .cluster.server" kubeconfig.yaml)
  kubectl --server "$KUBECONFIG_SERVER" --kubeconfig kubeconfig.yaml delete --ignore-not-found=true -f ${path.module}/manifests/ingress-nginx.yaml
EOT

  }
}

resource "null_resource" "wait_for_ip" {
  triggers = {
    trigger_id = random_id.trigger.hex
  }
  depends_on = [null_resource.wait_for_credentials, null_resource.apply_manifests]

  provisioner "local-exec" {
    command = <<-EOT
      KUBECONFIG_CONTEXT=$(yq e '.current-context' kubeconfig.yaml)
      KUBECONFIG_CLUSTER=$(yq e ".contexts[] | select(.name == \"$KUBECONFIG_CONTEXT\") | .context.cluster" kubeconfig.yaml)
      KUBECONFIG_SERVER=$(yq e ".clusters[] | select(.name == \"$KUBECONFIG_CLUSTER\") | .cluster.server" kubeconfig.yaml)

      until IP=$(kubectl --server "$KUBECONFIG_SERVER" --kubeconfig kubeconfig.yaml get service ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}') && echo $IP | grep -Eo '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$'; do
        echo "Waiting for LoadBalancer IP..."
        sleep 10
      done

      echo "lb_ip=$IP" > ${path.module}/lb_ip.env
    EOT
  }
}

resource "null_resource" "configure_kubectl" {
  depends_on = [null_resource.wait_for_credentials] # Adjust this dependency to match the resource that generates your kubeconfig.yaml file.

  provisioner "local-exec" {
    command = <<-EOT
      # Set the KUBECONFIG environment variable
      export KUBECONFIG=kubeconfig.yaml

      # OR Merge the new kubeconfig with an existing one (assuming you have kubectl and yq installed)
      if [ -f "$HOME/.kube/config" ]; then
        yq e -i '. as $item ireduce ({}; . * $item)' "$HOME/.kube/config" "kubeconfig.yaml"
      else
        mkdir -p "$HOME/.kube"
        cp "kubeconfig.yaml" "$HOME/.kube/config"
      fi
    EOT
  }
}





