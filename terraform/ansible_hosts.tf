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

resource "ansible_host" "ansible_vnc_servers" {
  count = length(module.servers.vnc_stagiaires_public_ips)
  inventory_hostname = "vnc-${element(var.stagiaires_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_stagiaires", "wireguard"]
  vars = {
    ansible_host = element(module.servers.vnc_stagiaires_public_ips, count.index)
    username = element(var.stagiaires_names, count.index)
    vpn_ip = "10.111.0.1${count.index}"
  }
}

resource "ansible_host" "ansible_vnc_servers_formateur" {
  count = length(var.formateurs_names)
  inventory_hostname = "vnc-formateur-${element(var.formateurs_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_formateur", "wireguard"]
  vars = {
    ansible_host = element(module.servers.vnc_formateurs_public_ips, count.index)
    username = element(var.formateurs_names, count.index)
    vpn_ip = "10.111.0.2${count.index}"
  }
}

resource "ansible_host" "ansible_guacamole_server" {
  inventory_hostname = "guacamole-server"
  groups = ["all", "scaleway", "guacamole_servers", "wireguard"]
  vars = {
    ansible_host = module.servers.guacamole_public_ip
    guacamole_domain = module.domains.guacamole_domain
    vpn_ip = "10.111.0.1"
  }
}

# resource "ansible_group" "vnc_servers" {
#   inventory_group_name = "vnc_servers"
#   vars = {
#     ansible_user = "root"
#   }
# }

