## Ansible mirroring hosts section
# Using https://github.com/nbering/terraform-provider-ansible/ to be installed manually (third party provider)
# Copy binary to ~/.terraform.d/plugins/

# resource "ansible_host" "ansible_vnc_nodes" {
#   count = "${local.vnc_node_count}"
#   inventory_hostname = "vnc-${count.index}"
#   groups = ["all", "scaleway", "vnc-cluster", "vnc-servers", "vnc-agents"]
#   vars = {
#     ansible_host = "${element(scaleway_instance_ip.vnc_node_ips.*.address, count.index)}"
#   }
# }

# resource "ansible_group" "all" {
#   inventory_group_name = "all"
#   vars = {
#     ansible_user = "root"
#   }
# }

# resource "ansible_group" "vnc-servers" {
#   inventory_group_name = "vnc-servers"
#   vars = {
#     vnc_control_node = true
#   }
# }

