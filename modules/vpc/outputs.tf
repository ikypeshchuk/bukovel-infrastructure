output "vpc_id" {
  value       = digitalocean_vpc.default.id
  description = "The ID of the VPC"
}

output "vpc_cidr_block" {
  value       = digitalocean_vpc.default.ip_range
  description = "The CIDR block of the VPC"
}
