resource "digitalocean_droplet" "local_runner" {
  image    = var.image
  name     = var.name
  region   = var.region
  size     = var.size
  ssh_keys = var.ssh_keys

  # Add the following line
  vpc_uuid = var.vpc_uuid
}


resource "null_resource" "local_runner_setup" {
  depends_on = [digitalocean_droplet.local_runner]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_ssh_key_path)
    host        = digitalocean_droplet.local_runner.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update",
      "apt-get upgrade -y -o Dpkg::Options::=\"--force-confold\"",
      # Install Docker
      "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "apt-get update -y",
      "apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
      "adduser --disabled-password --gecos \"\" ubuntu",
      "usermod -aG docker ubuntu",
      "mkdir /actions-runner && cd /actions-runner",
      "chown -R ubuntu:ubuntu /actions-runner",
      "cd /actions-runner",
      "export GITHUB_RUNNER_TOKEN='${var.github_runner_token}'",
      "export GITHUB_REPO_URL='${var.github_repo_url}'",
      "sudo -u ubuntu curl -o actions-runner-linux-x64-2.304.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.304.0/actions-runner-linux-x64-2.304.0.tar.gz",
      "sudo -u ubuntu tar xzf ./actions-runner-linux-x64-2.304.0.tar.gz",
      "sudo -u ubuntu ./config.sh --unattended --url $GITHUB_REPO_URL --token $GITHUB_RUNNER_TOKEN  --replace",
      "sudo -u ubuntu nohup ./run.sh &",
    ]
  }
}
