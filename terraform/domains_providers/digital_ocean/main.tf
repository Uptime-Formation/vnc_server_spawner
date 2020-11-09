
variable "digitalocean_token" {}

variable "stagiaires_names" {}
variable "formateurs_names" {}
variable "vnc_stagiaires_public_ips" {}
variable "vnc_formateurs_public_ips" {}
variable "guacamole_public_ip" {}

provider "digitalocean" {
  token = var.digitalocean_token
}

data "digitalocean_domain" "dopluk_domain" {
  name = "dopl.uk"
}

resource "digitalocean_record" "stagiaires_subdomains" {
  count = length(var.stagiaires_names)
  domain = data.digitalocean_domain.dopluk_domain.name
  type   = "A"
  name   = element(var.stagiaires_names, count.index)
  value  = element(var.vnc_stagiaires_public_ips, count.index)
}

resource "digitalocean_record" "formateurs_subdomains" {
  count = length(var.formateurs_names)
  domain = data.digitalocean_domain.dopluk_domain.name
  type   = "A"
  name   = element(var.formateurs_names, count.index)
  value  = element(var.vnc_formateurs_public_ips, count.index)
}

resource "digitalocean_record" "guacamole_node_subdomain" {
  domain = data.digitalocean_domain.dopluk_domain.name
  type   = "A"
  name   = "guacamole"
  value  = var.guacamole_public_ip
}

output "guacamole_domain" {
  value = "guacamole.${data.digitalocean_domain.dopluk_domain.name}"
}