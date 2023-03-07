# ## Ansible mirroring hosts section
# # Using https://github.com/nbering/terraform-provider-ansible/ to be installed manually (third party provider)
# # Copy binary to ~/.terraform.d/plugins/

terraform {
  required_providers {
    ansible = {
      source = "nbering/ansible"
      version = "1.0.4"
    }
  }
}


provider "ansible" {
  # Configuration options
}

variable "stagiaires_names" {}
variable "formateurs_names" {}
variable "vnc_stagiaires_public_ips" {}
variable "vnc_formateurs_public_ips" {}
variable "guacamole_public_ip" {}
variable "lxd_images_public_ip" {}
variable "global_lab_domain" {}

variable "formation_subdomain" {}


resource "ansible_host" "ansible_vnc_servers" {
  count = length(var.stagiaires_names)
  inventory_hostname = "vnc-${element(var.stagiaires_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_stagiaires", "wireguard"]
  vars = {
    ansible_host = element(var.vnc_stagiaires_public_ips, count.index)
    username = element(var.stagiaires_names, count.index)
    vpn_ip = "10.111.0.1${count.index}"
  }
}

resource "ansible_host" "ansible_vnc_servers_formateur" {
  count = length(var.formateurs_names)
  inventory_hostname = "vnc-formateur-${element(var.formateurs_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_formateur", "wireguard"]
  vars = {
    ansible_host = element(var.vnc_formateurs_public_ips, count.index)
    username = element(var.formateurs_names, count.index)
    vpn_ip = "10.111.0.2${count.index}"
  }
}

resource "ansible_host" "ansible_guacamole_server" {
  inventory_hostname = "guacamole.${var.formation_subdomain}.${var.global_lab_domain}"
  groups = ["all", "scaleway", "guacamole_servers", "wireguard", "k3s_cluster", "k3s_server"]
  vars = {
    ansible_host = var.guacamole_public_ip
    guacamole_domain = "guacamole.${var.formation_subdomain}.eliegavoty.xyz" # var.guacamole_domain
    vpn_ip = "10.111.0.1"
  }
}

