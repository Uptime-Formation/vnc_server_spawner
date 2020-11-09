variable "scaleway_api_access_key" {}
variable "scaleway_api_secret_key" {}
variable "scaleway_orga_id" {}

# Configure Scaleway Provider
provider "scaleway" {
  access_key      = var.scaleway_api_access_key
  secret_key      = var.scaleway_api_secret_key
  organization_id = var.scaleway_orga_id
  zone            = "fr-par-1"
  region          = "fr-par"
}

locals {
  vnc_servers = [
    "stagiaire1",
    "stagiaire2",
    # "stagiaire3",
    # "stagiaire4",
    # "stagiaire5",
    # "stagiaire6",
    # "stagiaire7",
  ]

  vnc_servers_formateur = [
    "elie",
    "hadrien",
  ]
}

resource "scaleway_instance_ip" "vnc_servers" {
  count = length(local.vnc_servers)
}

resource "scaleway_instance_ip" "vnc_servers_formateur" {
    count = length(local.vnc_servers_formateur)
}

resource "scaleway_instance_ip" "guacamole_server" {}

resource "scaleway_instance_server" "vnc_servers" {
  count = length(local.vnc_servers)
  name  = "vnc-server-${element(local.vnc_servers, count.index)}"
  type = "DEV1-L"
  image = "ubuntu-focal"
  ip_id = scaleway_instance_ip.vnc_servers[count.index].id
}

resource "scaleway_instance_server" "vnc_servers_formateur" {
  count = length(local.vnc_servers_formateur)
  name  = "vnc-server-formateur-${element(local.vnc_servers_formateur, count.index)}"
  type = "DEV1-L"
  image = "ubuntu-focal"
  ip_id = scaleway_instance_ip.vnc_servers_formateur[count.index].id

}

resource "scaleway_instance_server" "guacamole_server" {
  name  = "guacamole-server"
  type = "DEV1-L"
  image = "ubuntu_focal"
  ip_id = scaleway_instance_ip.guacamole_server.id
}