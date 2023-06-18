variable "stagiaires_names" {}
variable "formateurs_names" {}
variable "scaleway_api_secret_key" {}
variable "scaleway_api_access_key" {}
variable "scaleway_orga_id" {}
variable "servers_size" {}
variable "guac_servers_size" {}

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
  type  = var.servers_size
  # dirty firewalling trick: should set ufw ansible role
  security_group_id = scaleway_instance_security_group.vnc.id

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
  type  = var.servers_size
  # dirty firewalling trick: should set ufw ansible role
  security_group_id = scaleway_instance_security_group.vnc.id

  # scaleway automatically add available ssh keys from the account to every server (no need to do it manually)
}

resource "scaleway_instance_ip" "guacamole_server_ip" {
}

resource "scaleway_instance_server" "guacamole_server" {
  name  = "guacamole-server"
  image = "ubuntu_focal"
  ip_id = scaleway_instance_ip.guacamole_server_ip.id
  type  = var.guac_servers_size
  # scaleway automatically add available ssh keys from the account to every server (no need to do it manually)
}

# dirty firewalling trick: should set ufw ansible role
resource "scaleway_instance_security_group" "vnc" {
  inbound_default_policy  = "accept"
  outbound_default_policy = "accept"

  inbound_rule {
    action = "accept"
    port   = "5901"
    ip     = scaleway_instance_ip.guacamole_server_ip.address
  }
  inbound_rule {
    action = "accept"
    port   = "5901"
    ip     = scaleway_instance_server.guacamole_server.private_ip
  }

  inbound_rule {
    action = "drop"
    port   = "5901"
  }

}

output "vnc_stagiaires_public_ips" {
  value = scaleway_instance_ip.vnc_servers_stagiaires_ips.*.address
}

output "vnc_formateurs_public_ips" {
  value = scaleway_instance_ip.vnc_servers_formateurs_ips.*.address
}

output "vnc_stagiaires_private_ips" {
  value = scaleway_instance_server.vnc_servers_stagiaires.*.private_ip
}

output "vnc_formateurs_private_ips" {
  value = scaleway_instance_server.vnc_servers_formateurs.*.private_ip
}

output "guacamole_public_ip" {
  value = scaleway_instance_ip.guacamole_server_ip.address
}
