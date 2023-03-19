terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.23.0"
    }
    scaleway = {
      source = "scaleway/scaleway"
      version = "2.13.1"
    }
  }
}

# Providers are global and can be inherited automatically by modules
provider "scaleway" {
  access_key      = var.scaleway_api_access_key
  secret_key      = var.scaleway_api_secret_key
  organization_id = var.scaleway_orga_id
  zone            = "fr-par-1"
  region          = "fr-par"
}

 module "scaleway_servers" {
   count = var.servers_provider == "scaleway" ? 1 : 0
   source = "./servers_providers/scaleway"

   scaleway_api_secret_key = var.scaleway_api_secret_key
   scaleway_api_access_key = var.scaleway_api_access_key
   scaleway_orga_id        = var.scaleway_orga_id
   stagiaires_names        = var.stagiaires_names
   formateurs_names        = var.formateurs_names
 }

# Providers are global and can be inherited automatically by modules
provider "hcloud" {
  token = var.hcloud_token
}

module "hertzner_servers" {
  count = var.servers_provider == "hertzner"  ? 1 : 0
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
  stagiaires_names          = var.stagiaires_names
  formateurs_names          = var.formateurs_names
  vnc_stagiaires_public_ips = local.stagiaires_servers_public_ips
  vnc_formateurs_public_ips = local.formateurs_servers_public_ips
  guacamole_public_ip       = local.guacamole_public_ip
  lxd_images_public_ip      = local.lxd_images_public_ip
}


module "ansible_hosts" {
  source                    = "./ansible_hosts"
  stagiaires_names          = var.stagiaires_names
  formateurs_names          = var.formateurs_names
  vnc_stagiaires_public_ips = local.stagiaires_servers_public_ips
  vnc_formateurs_public_ips = local.formateurs_servers_public_ips
  guacamole_public_ip       = local.guacamole_public_ip
  lxd_images_public_ip      = local.lxd_images_public_ip

  guacamole_domain          = module.domains.guacamole_domain
}