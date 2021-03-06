# variable "hcloud_token" {}
variable "scaleway_api_secret_key" {}
variable "scaleway_api_access_key" {}
variable "scaleway_orga_id" {}

variable "ovh_application_key" {}
variable "ovh_application_secret" {}
variable "ovh_consumer_key" {}

module "servers" {
  source = "./servers_providers/scaleway"

  scaleway_api_secret_key = var.scaleway_api_secret_key
  scaleway_api_access_key = var.scaleway_api_access_key
  scaleway_orga_id        = var.scaleway_orga_id
  stagiaires_names        = var.stagiaires_names
  formateurs_names        = var.formateurs_names
}

# module "servers" {
#   source = "./servers_providers/hcloud"

#   hcloud_token = var.hcloud_token
#   stagiaires_names = var.stagiaires_names
#   formateurs_names = var.formateurs_names
# }


module "domains" {
  source                    = "./domains_providers/ovh"
  ovh_application_key       = var.ovh_application_key
  ovh_application_secret    = var.ovh_application_secret
  ovh_consumer_key          = var.ovh_consumer_key
  stagiaires_names          = var.stagiaires_names
  formateurs_names          = var.formateurs_names
  vnc_stagiaires_public_ips = module.servers.vnc_stagiaires_public_ips
  vnc_formateurs_public_ips = module.servers.vnc_formateurs_public_ips
  guacamole_public_ip       = module.servers.guacamole_public_ip
}

# module "domains" {
#   source                    = "./domains_providers/digital_ocean"
#   digitalocean_token        = var.digitalocean_token
#   stagiaires_names          = var.stagiaires_names
#   formateurs_names          = var.formateurs_names
#   vnc_stagiaires_public_ips = module.servers.vnc_stagiaires_public_ips
#   vnc_formateurs_public_ips = module.servers.vnc_formateurs_public_ips
#   guacamole_public_ip       = module.servers.guacamole_public_ip
# }
