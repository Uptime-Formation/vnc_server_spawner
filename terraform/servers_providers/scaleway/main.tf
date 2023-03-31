terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.13.1"
    }
  }
}

provider "scaleway" {
  access_key      = var.scaleway_api_access_key
  secret_key      = var.scaleway_api_secret_key
  organization_id = var.scaleway_orga_id
  zone            = "fr-par-1"
  region          = "fr-par"
}

resource "scaleway_instance_ip" "vnc_servers_stagiaires_ips" {
  count = length(var.stagiaires_names)
}

resource "scaleway_instance_server" "vnc_servers_stagiaires" {
  count = length(var.stagiaires_names)
  name  = "vnc-server-${element(var.stagiaires_names, count.index)}"
  image = "ubuntu_focal"
  ip_id = element(scaleway_instance_ip.vnc_servers_stagiaires_ips.*.id, count.index)
  type  = "DEV1-L"
  # scaleway automatically add available ssh keys from the account to every server (no need to do it manually)
}


resource "scaleway_instance_ip" "vnc_servers_formateurs_ips" {
  count = length(var.formateurs_names)
}

resource "scaleway_instance_server" "vnc_servers_formateurs" {
  count = length(var.formateurs_names)
  name  = "vnc-server-${element(var.formateurs_names, count.index)}"
  image = "ubuntu_focal"
  ip_id = element(scaleway_instance_ip.vnc_servers_formateurs_ips.*.id, count.index)
  type  = "DEV1-L"
  # scaleway automatically add available ssh keys from the account to every server (no need to do it manually)
}

resource "scaleway_instance_ip" "guacamole_server_ip" {
}

resource "scaleway_instance_server" "guacamole_server" {
  name  = "guacamole-server"
  image = "ubuntu_focal"
  ip_id = scaleway_instance_ip.guacamole_server_ip.id
  type  = "DEV1-L"
  # scaleway automatically add available ssh keys from the account to every server (no need to do it manually)
}
