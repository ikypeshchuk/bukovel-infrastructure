variable "name" {
  description = "The name of the local runner droplet"
  type        = string
}

variable "region" {
  description = "The region for the local runner droplet"
  type        = string
}

variable "size" {
  description = "The size of the local runner droplet"
  type        = string
}

variable "image" {
  description = "The image for the local runner droplet"
  type        = string
}

variable "ssh_keys" {
  description = "A list of SSH key fingerprints to be added to the local runner droplet"
  type        = list(string)
}

variable "private_ssh_key_path" {
  description = "The path to the private SSH key for accessing the local runner droplet"
  type        = string
}

variable "github_runner_token" {
  description = "The GitHub runner registration token"
  type        = string
  sensitive   = false
}

variable "github_repo_url" {
  description = "The GitHub repository URL"
  type        = string
}
# Add the following variable
variable "vpc_uuid" {
  description = "The UUID of the VPC to associate the local runner droplet with"
  type        = string
}
