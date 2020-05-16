## Ansible mirroring hosts section
# Using https://github.com/nbering/terraform-provider-ansible/ to be installed manually (third party provider)
# Copy binary to ~/.terraform.d/plugins/

resource "ansible_host" "ansible_vnc_servers" {
  count = length(local.vnc_servers)
  inventory_hostname = "vnc-${element(local.vnc_servers, count.index)}"
  groups = ["all", "hcloud", "vnc_servers", "vnc_servers_stagiaires"]
  vars = {
    ansible_host = element(hcloud_server.vnc_servers.*.ipv4_address, count.index)
  }
}

resource "ansible_host" "ansible_vnc_servers_formateur" {
  count = length(local.vnc_servers_formateur)
  inventory_hostname = "vnc-${element(local.vnc_servers_formateur, count.index)}"
  groups = ["all", "hcloud", "vnc_servers", "vnc_servers_formateur"]
  vars = {
    ansible_host = element(hcloud_server.vnc_servers_formateur.*.ipv4_address, count.index)
  }
}

# resource "ansible_group" "vnc_servers" {
#   inventory_group_name = "vnc_servers"
#   vars = {
#     ansible_user = "root"
#   }
# }

