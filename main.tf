terraform {
  required_version = ">= 0.13"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.5.0"
    }
  }
}
provider "digitalocean" {
  token = var.do_token
}
provider "kubernetes" {
  config_path = local.kubeconfig_exists ? local_file.kubeconfig.filename : ""
}
locals {
  kubeconfig_exists = fileexists("${path.module}/kubeconfig.yaml")
}
resource "local_file" "kubeconfig" {
  content    = module.kubernetes[0].kubeconfig_raw
  filename   = "${path.module}/kubeconfig.yaml"
  depends_on = [module.kubernetes]
}
resource "time_sleep" "wait_for_load_balancer" {
  depends_on = [module.kubernetes_resources.ingress_nginx_lb]

  create_duration = "3m" # Adjust the duration as needed
}
resource "null_resource" "cluster_dependency" {
  depends_on = [module.kubernetes]
}
resource "time_sleep" "wait_for_cluster" {
  depends_on      = [module.kubernetes]
  create_duration = "1m" # Adjust the duration as needed
}
module "vpc" {
  count    = var.enabled_modules["vpc"] ? 1 : 0
  source   = "./modules/vpc"
  vpc_name = "bukovel-fra1-vpc1"
  region   = "fra1"
  ip_range = "10.0.0.0/16"
}
module "kubernetes_resources" {
  count               = var.enabled_modules["kubernetes_resources"] ? 1 : 0
  depends_on          = [time_sleep.wait_for_cluster]
  source              = "./modules/kubernetes_resources"
  kubeconfig_filename = local_file.kubeconfig.filename
  cluster_dependency  = null_resource.cluster_dependency
}
module "kubernetes" {
  count                 = var.enabled_modules["kubernetes"] ? 1 : 0
  source                = "./modules/kubernetes"
  cluster_name          = "bukovel-k8s-cluster"
  region                = "fra1"
  do_kubernetes_version = "1.26.3-do.0"
  node_pool_name        = "worker-pool"
  node_size             = "s-1vcpu-2gb"
  min_node_count        = 1
  max_node_count        = 3
  registry_integration  = true
  vpc_uuid              = module.vpc[0].vpc_id
  depends_on            = [module.vpc, module.container_registry]
}
module "loadbalancer_letsencrypt_certificate" {
  count            = var.enabled_modules["loadbalancer_letsencrypt_certificate"] ? 1 : 0
  source           = "./modules/letsencrypt_certificate"
  project_domains  = ["dowebapi.brutskiy.fun"]
  certificate_name = "cert-dowebapi-brutskiy-fun"
  depends_on       = [module.dns_records, time_sleep.wait_for_load_balancer]
}
module "loadbalancer_dns_records" {
  count         = var.enabled_modules["loadbalancer_dns_records"] ? 1 : 0
  source        = "./modules/dns_records"
  domain_name   = "brutskiy.fun"
  create_domain = false
  depends_on    = [module.kubernetes_resources]
  records = [
    {
      name  = "@"
      type  = "A"
      value = try(module.kubernetes_resources[0].load_balancer_ip, "127.0.0.1")
      ttl   = 300
    },
    {
      name  = "dowebapi"
      type  = "A"
      value = try(module.kubernetes_resources[0].load_balancer_ip, "127.0.0.1")
      ttl   = 300
  }, ]
}
module "dns_records" {
  count         = var.enabled_modules["dns_records"] ? 1 : 0
  source        = "./modules/dns_records"
  domain_name   = "brutskiy.fun"
  create_domain = true
  records = [
    {
      name  = "bukovelwebapi"
      type  = "A"
      value = "95.216.47.151"
      ttl   = 300
    },
    {
      name  = "gitlab"
      type  = "A"
      value = "95.216.47.147"
      ttl   = 300
    },
    {
      name  = "www"
      type  = "CNAME"
      value = "@"
      ttl   = 300
    },
  ]
}
module "letsencrypt_certificate" {
  count            = var.enabled_modules["letsencrypt_certificate"] ? 1 : 0
  source           = "./modules/letsencrypt_certificate"
  project_domains  = ["dowebapi.brutskiy.fun"]
  certificate_name = "bukovel-dowebapi-certificate"
  depends_on       = [module.dns_records, module.loadbalancer_dns_records]
}
module "firewall" {
  count                  = var.enabled_modules["firewall"] ? 1 : 0
  source                 = "./modules/firewall"
  kubernetes_droplet_ids = module.kubernetes[0].node_pool_droplet_ids
  firewall_name          = "k8s-firewall"
  inbound_rules = [
    {
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
    {
      protocol         = "tcp"
      port_range       = "443"
      source_addresses = ["0.0.0.0/0", "::/0"]
    },
  ]
}
module "container_registry" {
  count             = var.enabled_modules["container_registry"] ? 1 : 0
  source            = "./modules/container_registry"
  registry_name     = "bukovel-registry"
  region            = "fra1"
  subscription_tier = "starter"
}
