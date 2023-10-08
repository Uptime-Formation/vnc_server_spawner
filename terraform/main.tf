# For servers and domains providers, use the symbolic links

module "ansible_hosts" {
  source                    = "./ansible_hosts"
  stagiaires_names          = var.stagiaires_names
  formateurs_names          = var.formateurs_names
  vnc_stagiaires_public_ips = local.stagiaires_servers_public_ips
  vnc_formateurs_public_ips = local.formateurs_servers_public_ips
  guacamole_public_ip       = local.guacamole_public_ip

  formation_subdomain = var.formation_subdomain
  global_lab_domain   = var.global_lab_domain
}