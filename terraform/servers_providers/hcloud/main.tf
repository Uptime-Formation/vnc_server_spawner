# Configure the Hetzner Cloud Provider
terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.23.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

data "hcloud_ssh_keys" "all_keys" {
}

data "hcloud_image" "image"{
  name = "ubuntu-20.04"
}

resource "hcloud_server" "vnc_servers_stagiaires" {
  count       = length(var.stagiaires_names)
  name        = "vnc-${element(var.stagiaires_names, count.index)}.${var.formation_subdomain}"
  server_type = var.vnc_server_type
  image       = data.hcloud_image.image.name
  location    = "hel1"
  ssh_keys    = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name
}

resource "hcloud_server" "vnc_servers_formateurs" {
  count       = length(var.formateurs_names)
  name        = "vnc-formateur-${element(var.formateurs_names, count.index)}.${var.formation_subdomain}"
  server_type = var.vnc_server_type
  image       =  data.hcloud_image.image.name
  location    = "hel1"
  ssh_keys    = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name
}

resource "hcloud_server" "guacamole_server" {
  name        = "guacamole-server.${var.formation_subdomain}"
  server_type = var.guacamole_server_type
  image       =  data.hcloud_image.image.name
  location    = "hel1"
  ssh_keys    = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name
}
