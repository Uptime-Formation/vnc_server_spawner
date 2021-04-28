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

variable "guacamole_domain" {}


resource "ansible_host" "ansible_vnc_servers" {
  count = length(var.stagiaires_names)
  inventory_hostname = "vnc-${element(var.stagiaires_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_stagiaires"]
  vars = {
    ansible_host = element(var.vnc_stagiaires_public_ips, count.index)
    username = element(var.stagiaires_names, count.index)
  }
}

resource "ansible_host" "ansible_vnc_servers_formateur" {
  count = length(var.formateurs_names)
  inventory_hostname = "vnc-formateur-${element(var.formateurs_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_formateur"]
  vars = {
    ansible_host = element(var.vnc_formateurs_public_ips, count.index)
    username = element(var.formateurs_names, count.index)
  }
}

resource "ansible_host" "ansible_guacamole_server" {
  inventory_hostname = "guacamole-server"
  groups = ["all", "scaleway", "guacamole_servers"]
  vars = {
    ansible_host = var.guacamole_public_ip
    guacamole_domain = var.guacamole_domain
  }
}

