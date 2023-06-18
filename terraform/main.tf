variable "scaleway_api_secret_key" {}
variable "scaleway_api_access_key" {}
variable "scaleway_orga_id" {}

module "servers" {
  source = "./servers_providers/scaleway"

  scaleway_api_secret_key = var.scaleway_api_secret_key
  scaleway_api_access_key = var.scaleway_api_access_key
  scaleway_orga_id        = var.scaleway_orga_id

  stagiaires_names        = var.stagiaires_names
  formateurs_names        = var.formateurs_names

  servers_size            = var.scaleway_vnc_servers_size
  guac_servers_size       = var.scaleway_guac_servers_size
}

module "ansible_hosts" {
  source                    = "./ansible_hosts"
  stagiaires_names          = var.stagiaires_names
  formateurs_names          = var.formateurs_names
  vnc_stagiaires_public_ips = module.servers.vnc_stagiaires_public_ips
  vnc_formateurs_public_ips = module.servers.vnc_formateurs_public_ips
  guacamole_public_ip       = module.servers.guacamole_public_ip
  #lxd_images_public_ip      = module.servers.lxd_images_public_ip

  guacamole_domain          = var.guacamole_domain
}
