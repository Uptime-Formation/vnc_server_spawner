variable "digitalocean_token" {}

variable "hcloud_token" {}
variable "hcloud_dns_token" {}

# variable "ovh_application_key" {}
# variable "ovh_application_secret" {}
# variable "ovh_consumer_key" {}

module "servers" {
  source = "./servers_providers/hcloud"

  hcloud_token              = var.hcloud_token
  formation_subdomain       = var.formation_subdomain
  stagiaires_names          = var.stagiaires_names
  formateurs_names          = var.formateurs_names
  vnc_server_type           = var.hcloud_vnc_server_type
  guacamole_server_type     = var.hcloud_guacamole_server_type
}


# module "domains" {
#   source                    = "./domains_providers/ovh"
#   ovh_application_key       = var.ovh_application_key
#   ovh_application_secret    = var.ovh_application_secret
#   ovh_consumer_key          = var.ovh_consumer_key
#   stagiaires_names          = var.stagiaires_names
#   formateurs_names          = var.formateurs_names
#   vnc_stagiaires_public_ips = module.servers.vnc_stagiaires_public_ips
#   vnc_formateurs_public_ips = module.servers.vnc_formateurs_public_ips
#   guacamole_public_ip       = module.servers.guacamole_public_ip
# }

module "domains" {
  source                    = "./domains_providers/digital_ocean"
  digitalocean_token        = var.digitalocean_token
  formation_subdomain       = var.formation_subdomain
  global_lab_domain         = var.global_lab_domain
  stagiaires_names          = var.stagiaires_names
  formateurs_names          = var.formateurs_names
  vnc_stagiaires_public_ips = module.servers.vnc_stagiaires_public_ips
  vnc_formateurs_public_ips = module.servers.vnc_formateurs_public_ips
  guacamole_public_ip       = module.servers.guacamole_public_ip
}

module "ansible_hosts" {
  source                    = "./ansible_hosts"
  stagiaires_names          = var.stagiaires_names
  formateurs_names          = var.formateurs_names
  vnc_stagiaires_public_ips = module.servers.vnc_stagiaires_public_ips
  vnc_formateurs_public_ips = module.servers.vnc_formateurs_public_ips
  guacamole_public_ip       = module.servers.guacamole_public_ip
  lxd_images_public_ip      = module.servers.lxd_images_public_ip
  formation_subdomain       = var.formation_subdomain
  global_lab_domain         = var.global_lab_domain

  # guacamole_domain          = module.domains.guacamole_domain
}