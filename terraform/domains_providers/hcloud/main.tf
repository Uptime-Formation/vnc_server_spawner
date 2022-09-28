
variable "hcloud_dns_token" {}

variable "formation_subdomain" {}

variable "stagiaires_names" {}
variable "formateurs_names" {}
variable "vnc_stagiaires_public_ips" {}
variable "vnc_formateurs_public_ips" {}
variable "guacamole_public_ip" {}
variable "lxd_images_public_ip" {}


terraform {
  required_providers {
    hetznerdns = {
      source = "timohirt/hetznerdns"
      version = "2.1.0"
    }
  }
}

provider "hetznerdns" {
  # Configuration options
  apitoken = var.hcloud_dns_token
}


data "hetznerdns_zone" "dopluk" {
    name = "dopl.uk"
}

resource "hetznerdns_record" "stagiaires_subdomains" {
  count = length(var.stagiaires_names)
  zone_id = data.hetznerdns_zone.dopluk.id
  type   = "A"
  ttl = 3600
  name   = "${element(var.stagiaires_names, count.index)}.${var.formation_subdomain}"
  value  = element(var.vnc_stagiaires_public_ips, count.index)
}

resource "hetznerdns_record" "stagiaires_wildcard_subdomains" {
  count = length(var.stagiaires_names)
  zone_id = data.hetznerdns_zone.dopluk.id
  type   = "A"
  ttl = 3600
  name   = "*.${element(var.stagiaires_names, count.index)}.${var.formation_subdomain}"
  value  = element(var.vnc_stagiaires_public_ips, count.index)
}

resource "hetznerdns_record" "formateurs_subdomains" {
  count = length(var.stagiaires_names)
  zone_id = data.hetznerdns_zone.dopluk.id
  type   = "A"
  ttl = 3600
  name   = "${element(var.formateurs_names, count.index)}.${var.formation_subdomain}"
  value  = element(var.vnc_formateurs_public_ips, count.index)
}

resource "hetznerdns_record" "formateurs_wildcard_subdomains" {
    count = length(var.stagiaires_names)
  zone_id = data.hetznerdns_zone.dopluk.id
  type   = "A"
  ttl = 3600
  name   = "*.${element(var.formateurs_names, count.index)}.${var.formation_subdomain}"
  value  = element(var.vnc_formateurs_public_ips, count.index)
}

resource "hetznerdns_record" "guacamole_node_subdomain" {
  zone_id = data.hetznerdns_zone.dopluk.id
  type   = "A"
  ttl = 3600
  name   = "guacamole.${var.formation_subdomain}"
  value  = var.guacamole_public_ip
}

output "guacamole_domain" {
  value = "guacamole.${var.formation_subdomain}.dopl.uk"
}