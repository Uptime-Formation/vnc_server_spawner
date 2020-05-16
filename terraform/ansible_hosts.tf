## Ansible mirroring hosts section
# Using https://github.com/nbering/terraform-provider-ansible/ to be installed manually (third party provider)
# Copy binary to ~/.terraform.d/plugins/

resource "ansible_host" "ansible_vnc_servers" {
  count = length(local.vnc_servers)
  inventory_hostname = "vnc-${element(hcloud_server.vnc_servers, count.index)}"
  groups = ["all", "hcloud", "vnc-servers"]
  vars = {
    ansible_host = element(hcloud_server.vnc_servers.*.ipv4_address, count.index)
  }
}

resource "ansible_group" "vnc-servers" {
  inventory_group_name = "vnc-servers"
  vars = {
    ansible_user = "root"
  }
}

