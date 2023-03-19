
locals{
  stagiaires_servers_public_ips = var.servers_provider == "scaleway" ? module.scaleway_servers[0].vnc_stagiaires_public_ips : module.hertzner_servers[0].vnc_stagiaires_public_ips
  formateurs_servers_public_ips = var.servers_provider == "scaleway" ? module.scaleway_servers[0].vnc_formateurs_public_ips : module.hertzner_servers[0].vnc_formateurs_public_ips
  guacamole_public_ip = var.servers_provider == "scaleway" ? module.scaleway_servers[0].guacamole_public_ip : module.hertzner_servers[0].guacamole_public_ip
  lxd_images_public_ip = var.servers_provider == "scaleway" ? module.scaleway_servers[0].lxd_images_public_ip : module.hertzner_servers[0].lxd_images_public_ip
}
