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

data "hcloud_image" "image_by_name"{
  count = length(var.hcloud_image_id) > 1 ? 0 : 1
  name  = var.hcloud_image_name
}

data "hcloud_image" "image_by_id"{
  count = length(var.hcloud_image_id) > 1 ? 1 : 0
  id    = var.hcloud_image_id
}

locals {
  image = length(var.hcloud_image_id) > 1 ? data.hcloud_image.image_by_id[0]: data.hcloud_image.image_by_name[0]
}

resource "hcloud_server" "vnc_servers_stagiaires" {
  count       = length(var.stagiaires_names)
  name        = "vnc-${element(var.stagiaires_names, count.index)}.${var.formation_subdomain}"
  server_type = var.vnc_server_type
  image       = local.image.id
  location    = "hel1"
  ssh_keys    = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name
}

resource "hcloud_server" "vnc_servers_formateurs" {
  count       = length(var.formateurs_names)
  name        = "vnc-formateur-${element(var.formateurs_names, count.index)}.${var.formation_subdomain}"
  server_type = var.vnc_server_type
  image       =  local.image.id
  location    = "hel1"
  ssh_keys    = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name
}

resource "hcloud_server" "guacamole_server" {
  name        = "guacamole-server.${var.formation_subdomain}"
  server_type = var.guacamole_server_type
  image       =  local.image.id
  location    = "hel1"
  ssh_keys    = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name
}
