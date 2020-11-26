## Ansible mirroring hosts section
# Using https://github.com/nbering/terraform-provider-ansible/ to be installed manually (third party provider)
# Copy binary to ~/.terraform.d/plugins/

resource "ansible_host" "ansible_vnc_servers" {
  count = length(module.servers.vnc_stagiaires_public_ips)
  inventory_hostname = "vnc-${element(var.stagiaires_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_stagiaires"]
  vars = {
    ansible_host = element(module.servers.vnc_stagiaires_public_ips, count.index)
    username = element(var.stagiaires_names, count.index)
  }
}

resource "ansible_host" "ansible_vnc_servers_formateur" {
  count = length(var.formateurs_names)
  inventory_hostname = "vnc-formateur-${element(var.formateurs_names, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_formateur"]
  vars = {
    ansible_host = element(module.servers.vnc_formateurs_public_ips, count.index)
    username = element(var.formateurs_names, count.index)
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

resource "ansible_host" "ansible_bbb_server" {
  inventory_hostname = "bbb-server"
  groups = ["all", "scaleway", "bbb_servers"]
  vars = {
    ansible_host = module.servers.bbb_public_ip
    bbb_domain = module.domains.bbb_domain
  }
}

# resource "ansible_group" "vnc_servers" {
#   inventory_group_name = "vnc_servers"
#   vars = {
#     ansible_user = "root"
#   }
# }

