## Ansible mirroring hosts section
# Using https://github.com/nbering/terraform-provider-ansible/ to be installed manually (third party provider)
# Copy binary to ~/.terraform.d/plugins/

resource "ansible_host" "ansible_vnc_servers" {
  count = length(local.vnc_servers)
  inventory_hostname = "vnc-${element(local.vnc_servers, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_stagiaires"]
  # groups = ["all", "hcloud", "vnc_servers", "vnc_servers_stagiaires"]
  vars = {
    ansible_host = element(scaleway_instance_server.vnc_servers.*.public_ip, count.index)
    # ansible_host = element(hcloud_server.vnc_servers.*.ipv4_address, count.index)
    username = element(local.vnc_servers, count.index)
  }
}

resource "ansible_host" "ansible_vnc_servers_formateur" {
  count = length(local.vnc_servers_formateur)
  inventory_hostname = "vnc-formateur-${element(local.vnc_servers_formateur, count.index)}"
  groups = ["all", "scaleway", "vnc_servers", "vnc_servers_formateur"]
  vars = {
    ansible_host = element(scaleway_instance_server.vnc_servers_formateur.*.public_ip, count.index)
    username = element(local.vnc_servers_formateur, count.index)
  }
}

resource "ansible_host" "ansible_guacamole_server" {
  inventory_hostname = "guacamole-server"
  groups = ["all", "scaleway", "guacamole_servers"]
  vars = {
    ansible_host = scaleway_instance_server.guacamole_server.public_ip
  }
}

# resource "ansible_group" "vnc_servers" {
#   inventory_group_name = "vnc_servers"
#   vars = {
#     ansible_user = "root"
#   }
# }

