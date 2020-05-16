variable "hcloud_token" {}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

locals {
  vnc_servers = [
    "akitani",
    "chumillas",
  ]
  vnc_servers_formateur = [
    "formateur",
  ]
}


resource "hcloud_server" "vnc_servers" {
  count = length(local.vnc_servers)
  name  = "vnc-server-${element(local.vnc_servers, count.index)}"
  server_type = "cx21"
  image = "ubuntu-18.04"
  location = "nbg1"
  ssh_keys = ["lenox-main"]
}

resource "hcloud_server" "vnc_servers_formateur" {
  count = length(local.vnc_servers_formateur)
  name  = "vnc-server-${element(local.vnc_servers_formateur, count.index)}"
  server_type = "cx21"
  image = "ubuntu-18.04"
  location = "nbg1"
  ssh_keys = ["lenox-main"]
}