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
}

resource "scaleway_instance_ip" "vnc_node_ips" {
  count = local.vnc_node_count
}

resource "scaleway_instance_server" "vnc_nodes" {
  count = local.vnc_node_count
  name  = "vnc_node_${count.index}"
  image = "ac453298-264d-425b-82a9-5c1a3d8e34a3" // "vncserver-base-202005"
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
