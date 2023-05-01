terraform {
  required_version = ">= 0.13"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.0.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

module "kubernetes" {
  source                = "./modules/kubernetes"
  cluster_name          = "bukovel-k8s-cluster"
  region                = "fra1"
  do_kubernetes_version = "1.26.3-do.0"
  node_pool_name        = "worker-pool"
  node_size             = "s-1vcpu-2gb"
  min_node_count        = 2
  max_node_count        = 12
  registry_integration  = true
  vpc_uuid              = module.vpc.vpc_id
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_name = "bukovel-vpc"
  region   = "fra1"
  ip_range = "10.0.0.0/16"
}
module "loadbalancer" {
  source            = "./modules/loadbalancer"
  loadbalancer_name = "my-loadbalancer"
  region            = "fra1"
  vpc_uuid          = module.vpc.vpc_id
  forwarding_rules = [
    {
      entry_protocol  = "http"
      entry_port      = 80
      target_protocol = "http"
      target_port     = 80
      certificate_id  = ""
      tls_passthrough = false
    },
    {
      entry_protocol  = "https"
      entry_port      = 443
      target_protocol = "http"
      target_port     = 80
      certificate_id  = module.letsencrypt_certificate.cert_id
      tls_passthrough = false
    },
  ]
}

module "firewall" {
  source                 = "./modules/firewall"
  kubernetes_droplet_ids = module.kubernetes.node_pool_droplet_ids
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
module "letsencrypt_certificate" {
  source          = "./modules/letsencrypt_certificate"
  project_domains = ["dowebapi.brutskiy.fun"]
}

module "postgres" {
  source        = "./modules/postgres"
  db_name       = "bukovel-postgres"
  db_version    = "13"
  db_size       = "db-s-1vcpu-1gb"
  db_region     = "fra1"
  db_node_count = 1
  vpc_uuid      = module.vpc.vpc_id
}

module "container_registry" {
  source            = "./modules/container_registry"
  registry_name     = "bukovel-registry"
  region            = "fra1"
  subscription_tier = "starter"
}

module "dns_records" {
  source      = "./modules/dns_records"
  domain_name = "dowebapi.brutskiy.fun"
  records = [
    {
      name  = "@"
      type  = "A"
      value = module.loadbalancer.ip_address
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
