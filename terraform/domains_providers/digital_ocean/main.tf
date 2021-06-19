
variable "digitalocean_token" {}

variable "formation_subdomain" {}

variable "stagiaires_names" {}
variable "formateurs_names" {}
variable "vnc_stagiaires_public_ips" {}
variable "vnc_formateurs_public_ips" {}
variable "guacamole_public_ip" {}
variable "lxd_images_public_ip" {}

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.2.0"
    }
  }
}

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
  name   = "${element(var.stagiaires_names, count.index)}.${var.formation_subdomain}"
  value  = element(var.vnc_stagiaires_public_ips, count.index)
}

resource "digitalocean_record" "stagiaires_wildcard_subdomains" {
  count = length(var.stagiaires_names)
  domain = data.digitalocean_domain.dopluk_domain.name
  type   = "A"
  name   = "*.${element(var.stagiaires_names, count.index)}.${var.formation_subdomain}"
  value  = element(var.vnc_stagiaires_public_ips, count.index)
}

resource "digitalocean_record" "formateurs_subdomains" {
  count = length(var.formateurs_names)
  domain = data.digitalocean_domain.dopluk_domain.name
  type   = "A"
  name   = "${element(var.formateurs_names, count.index)}.${var.formation_subdomain}"
  value  = element(var.vnc_formateurs_public_ips, count.index)
}

resource "digitalocean_record" "formateurs_wildcard_subdomains" {
  count = length(var.formateurs_names)
  domain = data.digitalocean_domain.dopluk_domain.name
  type   = "A"
  name   = "*.${element(var.formateurs_names, count.index)}.${var.formation_subdomain}"
  value  = element(var.vnc_formateurs_public_ips, count.index)
}

resource "digitalocean_record" "guacamole_node_subdomain" {
  domain = data.digitalocean_domain.dopluk_domain.name
  type   = "A"
  name   = "guacamole.${var.formation_subdomain}"
  value  = var.guacamole_public_ip
}

resource "digitalocean_record" "lxd_images_node_subdomain" {
  domain = data.digitalocean_domain.dopluk_domain.name
  type   = "A"
  name   = "lxd-images.${var.formation_subdomain}"
  value  = var.lxd_images_public_ip
}

output "guacamole_domain" {
  value = "guacamole.${var.formation_subdomain}.${data.digitalocean_domain.dopluk_domain.name}"
}