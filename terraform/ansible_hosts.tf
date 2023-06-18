# ## Ansible mirroring hosts section
# # Using https://github.com/nbering/terraform-provider-ansible/ to be installed manually (third party provider)
# # Copy binary to ~/.terraform.d/plugins/


# variable "stagiaires_names" {}
# variable "formateurs_names" {}
# variable "formateurs_password" {}
# variable "stagiaires_password" {}

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




resource "ansible_host" "ansible_vnc_servers_stagiaires" {
  count = length(module.servers.vnc_stagiaires_public_ips)
  inventory_hostname = "vnc-${element(var.stagiaires_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_stagiaires"]
  vars = {
    ansible_host = element(module.servers.vnc_stagiaires_public_ips, count.index)
    # private_ip = element(module.servers.vnc_stagiaires_private_ips, count.index)
    username = element(var.stagiaires_names, count.index)
    base_unix_user = element(var.stagiaires_names, count.index)
    vnc_unix_user = element(var.stagiaires_names, count.index)
    # vnc_passwd = var.stagiaires_password
    # base_user_password = var.stagiaires_password
    # guac_passwd = var.stagiaires_password
  }
}

resource "ansible_host" "ansible_vnc_servers_formateurs" {
  count = length(var.formateurs_names)
  inventory_hostname = "vnc-formateur-${element(var.formateurs_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_formateurs"]
  vars = {
      ansible_host = element(module.servers.vnc_formateurs_public_ips, count.index)
    #   private_ip = element(module.servers.vnc_formateurs_private_ips, count.index)
      username = element(var.formateurs_names, count.index)
      base_unix_user = element(var.formateurs_names, count.index)
      vnc_unix_user = element(var.formateurs_names, count.index)
    #   vnc_passwd = var.formateurs_password
    #   base_user_password = var.formateurs_password
    #   guac_passwd = var.formateurs_password
  }
}



resource "ansible_host" "ansible_guacamole_server" {
  inventory_hostname = "guacamole-server"
  groups = ["all", "scaleway", "guacamole_servers"]
  vars = {
    ansible_host = module.servers.guacamole_public_ip
    guacamole_domain = var.guacamole_domain
  }
}



# resource "ansible_group" "vnc_servers" {
#   inventory_group_name = "vnc_servers"
#   vars = {
#     ansible_user = "root"
#   }
# }

