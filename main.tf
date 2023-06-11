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

# -------------------------------------------------------------------------------------------------------
provider "digitalocean" {
  token = var.do_token
}

provider "kubernetes" {
  config_path = local.kubeconfig_exists ? local_file.kubeconfig.filename : ""
}

# -------------------------------------------------------------------------------------------------------
locals {
  kubeconfig_exists = fileexists("${path.module}/kubeconfig.yaml")
  cluster_name      = format(
    "%s-%s-%s",
    var.conf["name"],
    var.conf["enviroment"],
    var.conf["region"]
  )
}

# -------------------------------------------------------------------------------------------------------
resource "local_file" "kubeconfig" {
  content    = length(module.kubernetes) > 0 ? module.kubernetes[0].kubeconfig_raw : ""
  filename   = "${path.module}/kubeconfig.yaml"
  depends_on = [module.kubernetes]
}

resource "null_resource" "cluster_dependency" {
  depends_on = [module.kubernetes]
}

resource "time_sleep" "wait_for_load_balancer" {
  depends_on = [module.loadbalancer_dns_records.ingress_nginx_lb]
  create_duration = "1m" # Adjust the duration as needed
}

resource "time_sleep" "wait_for_cluster" {
  depends_on      = [module.kubernetes]
  create_duration = "1m" # Adjust the duration as needed
}

# -------------------------------------------------------------------------------------------------------
module "vpc" {
  count    = var.enabled_modules["vpc"] ? 1 : 0
  source   = "./modules/vpc"
  vpc_name = "${local.cluster_name}-vpc"
  region   = var.conf["region"]
  ip_range = "10.0.0.0/16"
}

module "postgresql" {
  count         = var.enabled_modules["postgresql"] ? 1 : 0
  source        = "./modules/postgres"
  vpc_uuid      = module.vpc[0].vpc_id
  depends_on    = [module.vpc]
  db_name       = "${local.cluster_name}-postgresql"
  db_node_count = 1
  db_region     = var.conf["region"]
  db_size       = "db-s-1vcpu-1gb"
  db_version    = 15
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
  cluster_name          = "${local.cluster_name}-k8s-cluster"
  region                = var.conf["region"]
  do_kubernetes_version = "1.26.5-do.0"
  node_pool_name        = "${local.cluster_name}-worker-pool"
  node_size             = "s-1vcpu-2gb"
  min_node_count        = 1
  max_node_count        = 3
  registry_integration  = true
  vpc_uuid              = module.vpc[0].vpc_id
  depends_on            = [module.vpc, module.container_registry, module.postgresql]
}

module "loadbalancer_letsencrypt_certificate" {
  count            = var.enabled_modules["loadbalancer_letsencrypt_certificate"] ? 1 : 0
  source           = "./modules/letsencrypt_certificate"
  project_domains  = ["doapi.brutskiy.fun"]
  certificate_name = "${local.cluster_name}-cert-doapi-brutskiy-fun"
  depends_on       = [module.dns_records, time_sleep.wait_for_load_balancer]
}

module "loadbalancer_dns_records" {
  count         = var.enabled_modules["loadbalancer_dns_records"] ? 1 : 0
  source        = "./modules/dns_records"
  domain_name   = "brutskiy.fun"
  create_domain = false
  depends_on    = [module.kubernetes_resources, time_sleep.wait_for_load_balancer]
  records = [
    {
      name  = "@"
      type  = "A"
      value = try(module.kubernetes_resources[0].load_balancer_ip, "127.0.0.1")
      ttl   = 300
    },
    {
      name  = "doapi"
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
  certificate_name = "${local.cluster_name}-dowebapi-certificate"
  depends_on       = [module.dns_records, module.loadbalancer_dns_records]
}

module "firewall" {
  count                  = var.enabled_modules["firewall"] ? 1 : 0
  source                 = "./modules/firewall"
  kubernetes_droplet_ids = module.kubernetes[0].node_pool_droplet_ids
  firewall_name          = "${local.cluster_name}-k8s-firewall"
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
  registry_name     = "${local.cluster_name}-registry"
  region            = var.conf["region"]
  subscription_tier = "starter"
}

module "local_runner" {
  count                = var.enabled_modules["local_runner"] ? 1 : 0
  source               = "./modules/local_runner"
  name                 = "${local.cluster_name}-local-runner"
  region               = var.conf["region"]
  size                 = "s-1vcpu-2gb"
  image                = "ubuntu-22-04-x64"
  ssh_keys             = [var.ssh_key_fingerprint]
  private_ssh_key_path = var.private_ssh_key_path
  github_runner_token  = var.github_runner_token
  github_repo_url      = var.github_repo_url
  vpc_uuid             = module.vpc[0].vpc_id
  #depends_on           = [module.dns_records]
}
