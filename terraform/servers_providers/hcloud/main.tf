variable "hcloud_token" {}
variable "stagiaires_names" {}
variable "formateurs_names" {}

# Configure the Hetzner Cloud Provider
terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.23.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_server" "vnc_servers_stagiaires" {
  count = length(var.stagiaires_names)
  name  = "vnc-server-${element(var.stagiaires_names, count.index)}"
  server_type = "cx31"
  image = "ubuntu-20.04"
  location = "hel1"
  ssh_keys = ["id-guacamole-infra"]
}

resource "hcloud_server" "vnc_servers_formateurs" {
  count = length(var.formateurs_names)
  name  = "vnc-server-formateur-${element(var.formateurs_names, count.index)}"
  server_type = "cx31"
  image = "ubuntu-20.04"
  location = "hel1"
  ssh_keys = ["id-guacamole-infra"]
}

resource "hcloud_server" "guacamole_server" {
  name  = "guacamole-server"
  server_type = "cx11"
  image = "ubuntu-20.04"
  location = "hel1"
  ssh_keys = ["id-guacamole-infra"]
}

output "vnc_stagiaires_public_ips" {
  value = hcloud_server.vnc_servers_stagiaires.*.ipv4_address
}

output "vnc_formateurs_public_ips" {
  value = hcloud_server.vnc_servers_formateurs.*.ipv4_address
}

output "guacamole_public_ip" {
  value = hcloud_server.guacamole_server.ipv4_address
}

output "lxd_images_public_ip" {
  value = hcloud_server.vnc_servers_formateurs.0.ipv4_address
}
