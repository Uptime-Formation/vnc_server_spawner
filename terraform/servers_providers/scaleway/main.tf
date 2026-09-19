terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.52"
    }
  }
}

provider "scaleway" {
  access_key      = var.scaleway_api_access_key
  secret_key      = var.scaleway_api_secret_key
  organization_id = var.scaleway_orga_id
  # @alban: was hardcoded to fr-par-2 until 2026-09-19, which never
  # matched the zone Packer builds/resolves the xubuntu image in
  # (fr-par-1) -- Scaleway images are zone-scoped, so that mismatch
  # made `terraform apply` fail with "resource instance_image with ID
  # ... is not found" even though the image genuinely existed, just in
  # the other zone. Now a shared variable (default "fr-par-1", set in
  # terraform/variables.tf) so Packer and Terraform can't drift apart
  # on zone again -- see packer/xubuntu_remote_desktop_server.json's
  # {{user `scaleway_zone`}}.
  zone            = var.scaleway_zone
  region          = "fr-par"
}

data "scaleway_instance_image" "image_by_name"{
  count = length(var.scaleway_image_id) > 1 ? 0 : 1
  name  = var.scaleway_image_name
}

data "scaleway_instance_image" "image_by_id"{
  count = length(var.scaleway_image_id) > 1 ? 1 : 0
  image_id    = var.scaleway_image_id
}

locals {
  image = length(var.scaleway_image_id) > 1 ? data.scaleway_instance_image.image_by_id[0]: data.scaleway_instance_image.image_by_name[0]
}

resource "scaleway_instance_ip" "vnc_servers_stagiaires_ips" {
  count = length(var.stagiaires_names)
}

resource "scaleway_instance_server" "vnc_servers_stagiaires" {
  count = length(var.stagiaires_names)
  name  = "vnc-server-${element(var.stagiaires_names, count.index)}"
  image = local.image.id
  ip_id = element(scaleway_instance_ip.vnc_servers_stagiaires_ips.*.id, count.index)
  type  = var.vnc_server_type
  # scaleway automatically add available ssh keys from the account to every server (no need to do it manually)
}


resource "scaleway_instance_ip" "vnc_servers_formateurs_ips" {
  count = length(var.formateurs_names)
}

resource "scaleway_instance_server" "vnc_servers_formateurs" {
  count = length(var.formateurs_names)
  name  = "vnc-server-${element(var.formateurs_names, count.index)}"
  image = local.image.id
  ip_id = element(scaleway_instance_ip.vnc_servers_formateurs_ips.*.id, count.index)
  type  = var.vnc_server_type
  # scaleway automatically add available ssh keys from the account to every server (no need to do it manually)
}

resource "scaleway_instance_ip" "guacamole_server_ip" {
}

resource "scaleway_instance_server" "guacamole_server" {
  name  = "guacamole-server"
  image = local.image.id
  ip_id = scaleway_instance_ip.guacamole_server_ip.id
  type  = var.guacamole_server_type
  # scaleway automatically add available ssh keys from the account to every server (no need to do it manually)
}
