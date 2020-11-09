# variable "hcloud_token" {}
variable "scaleway_api_secret_key" {}
variable "scaleway_api_access_key" {}
variable "scaleway_orga_id" {}


module "servers" {
  source = "./servers_providers/scaleway"

  scaleway_api_secret_key = var.scaleway_api_secret_key
  scaleway_api_access_key = var.scaleway_api_access_key
  scaleway_orga_id = var.scaleway_orga_id
  stagiaires_names = var.stagiaires_names
  formateurs_names = var.formateurs_names
}

# module "servers" {
#   source = "./servers_providers/hcloud"

#   hcloud_token = var.hcloud_token
#   stagiaires_names = var.stagiaires_names
#   formateurs_names = var.formateurs_names
# }