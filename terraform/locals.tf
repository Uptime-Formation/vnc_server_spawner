
locals {
  formateurs_servers_public_ips = module.servers.vnc_formateurs_public_ips
  global_lab_domain             = module.domains.global_lab_domain
  guacamole_public_ip           = module.servers.guacamole_public_ip
  lxd_images_public_ip          = module.servers.lxd_images_public_ip
  stagiaires_servers_public_ips = module.servers.vnc_stagiaires_public_ips
}
