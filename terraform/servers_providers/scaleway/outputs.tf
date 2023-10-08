
output "vnc_stagiaires_public_ips" {
  value = scaleway_instance_ip.vnc_servers_stagiaires_ips.*.address
}

output "vnc_formateurs_public_ips" {
  value = scaleway_instance_ip.vnc_servers_formateurs_ips.*.address
}

output "guacamole_public_ip" {
  value = scaleway_instance_ip.guacamole_server_ip.address
}
