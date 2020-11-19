## Ansible mirroring hosts section
# Using https://github.com/nbering/terraform-provider-ansible/ to be installed manually (third party provider)
# Copy binary to ~/.terraform.d/plugins/

# locals {
#   stagiaires_names = [for stagiaire in var.stagiaires: stagiaire.name]
#   formateurs_names = [for formateur in var.formateurs: formateur.name]
# }

resource "ansible_host" "ansible_vnc_servers_stagiaires" {
  count = length(module.servers.vnc_stagiaires_public_ips)
  inventory_hostname = "vnc-${element(local.stagiaires_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_stagiaires"]
  vars = {
    ansible_host = element(module.servers.vnc_stagiaires_public_ips, count.index)
    username = element(local.stagiaires_names, count.index)
    base_unix_user = element(local.stagiaires_names, count.index)
    vnc_unix_user = element(local.stagiaires_names, count.index)
    vnc_passwd = element(var.stagiaires, count.index).password
    base_user_password = element(var.stagiaires, count.index).password
    guac_passwd = element(var.stagiaires, count.index).password
  }
}

resource "ansible_host" "ansible_vnc_servers_formateurs" {
  count = length(local.formateurs_names)
  inventory_hostname = "vnc-formateur-${element(local.formateurs_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_formateurs"]
  vars = {
      ansible_host = element(module.servers.vnc_formateurs_public_ips, count.index)
      username = element(local.formateurs_names, count.index)
      base_unix_user = element(local.formateurs_names, count.index)
      vnc_unix_user = element(local.formateurs_names, count.index)
      vnc_passwd = element(var.formateurs, count.index).password
      base_user_password = element(var.formateurs, count.index).password
      guac_passwd = element(var.formateurs, count.index).password

  }
}

resource "ansible_host" "ansible_guacamole_server" {
  inventory_hostname = "guacamole-server"
  groups = ["all", "scaleway", "guacamole_servers"]
  vars = {
    ansible_host = module.servers.guacamole_public_ip
    guacamole_domain = module.domains.guacamole_domain
  }
}

# resource "ansible_group" "vnc_servers" {
#   inventory_group_name = "vnc_servers"
#   vars = {
#     ansible_user = "root"
#   }
# }

