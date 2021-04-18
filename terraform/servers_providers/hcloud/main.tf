variable "hcloud_token" {}
variable "hcloud_ssh_keys" {}

variable "formation_subdomain" {}
variable "stagiaires_names" {}
variable "formateurs_names" {}
variable "vnc_server_type" {}
variable "guacamole_server_type" {}

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
  image = "ubuntu-20.04"
  ssh_keys = var.hcloud_ssh_keys
  name  = "vnc-${element(var.stagiaires_names, count.index)}.${var.formation_subdomain}"
  server_type = var.vnc_server_type
  location = "hel1"
}

resource "hcloud_server" "vnc_servers_formateurs" {
  count = length(var.formateurs_names)

  name  = "vnc-formateur-${element(var.formateurs_names, count.index)}.${var.formation_subdomain}"
  server_type = var.vnc_server_type 

  image = "ubuntu-20.04"
  location = "nbg1"
  ssh_keys = var.hcloud_ssh_keys
#   ssh_keys = ["lenox-main"]
}

resource "hcloud_server" "guacamole_server" {
  image = "ubuntu-20.04"
  ssh_keys = var.hcloud_ssh_keys

  name  = "guacamole-server.${var.formation_subdomain}"
  server_type = var.guacamole_server_type
  location = "hel1"
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
