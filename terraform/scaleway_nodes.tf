variable "scaleway_api_secret_key" {}
variable "scaleway_api_access_key" {}
variable "scaleway_orga_id" {}

provider "scaleway" {
  access_key      = var.scaleway_api_access_key
  secret_key      = var.scaleway_api_secret_key
  organization_id = var.scaleway_orga_id
  zone            = "fr-par-1"
  region          = "fr-par"
}


locals {
  vnc_node_count = 2
  vnc_servers = [
    "formateur",
    "akitani",
    "chumillas",
    "leclerc",
    "dubuisson",
    "tafforin",
    "Kamycki",
    "dmapesa",
    "bouzid",
    "sallem",
    "mesoik",
    "malombe",
    "csaada",
    "energeault",
    "leguillant",
  ]
}

resource "scaleway_instance_ip" "vnc_node_ips" {
  count = length(local.vnc_servers) 
}

resource "scaleway_instance_server" "vnc_nodes" {
  count = length(local.vnc_servers)
  name  = "vnc_node_${element(local.vnc_servers, count.index)}"
  image = "5cb29c01-5f3a-4ea2-82aa-be0d6851ab55" // "vncserver-base3-202005" prebuild VPS image
  // image = "ubuntu-bionic" // for use with ansible installation
  ip_id = "${element(scaleway_instance_ip.vnc_node_ips.*.id, count.index)}"
  type  = "DEV1-L"
  # scaleway automatically add available ssh keys from the account to every server (no need to do it manually)
}

# data "scaleway_instance_image" "debian_stretch" {
#   name  = "Debian Stretch"
# }

# output "debian_image" {
#   value = data.scaleway_instance_image.debian_stretch
# }
