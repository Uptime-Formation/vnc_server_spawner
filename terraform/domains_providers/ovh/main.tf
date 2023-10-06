
terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "0.29.0"
    }
  }
}

terraform {
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = var.ovh_application_key
  application_secret = var.ovh_application_secret
  consumer_key       = var.ovh_consumer_key
}

data "ovh_domain_zone" "doxx_domain" {
  name = "doxx.fr"
}


resource "ovh_domain_zone_record" "stagiaires_subdomains" {
  count     = length(var.stagiaires_names)
  zone      = data.ovh_domain_zone.doxx_domain.name
  subdomain = "${element(var.stagiaires_names, count.index)}.${var.formation_subdomain}"
  fieldtype = "A"
  ttl       = "180"
  target    = element(var.vnc_stagiaires_public_ips, count.index)
}

resource "ovh_domain_zone_record" "formateurs_subdomains" {
  count = length(var.formateurs_names)
  zone  = data.ovh_domain_zone.doxx_domain.name
  # subdomain = element(scaleway_instance_server.vnc_servers.*.public_ip, count.index)
  subdomain = "${element(var.formateurs_names, count.index)}.${var.formation_subdomain}"
  fieldtype = "A"
  ttl       = "0"
  target    = element(var.vnc_formateurs_public_ips, count.index)
}

resource "ovh_domain_zone_record" "stagiaires_wildcard_subdomains" {
  count     = length(var.stagiaires_names)
  zone      = data.ovh_domain_zone.doxx_domain.name
  subdomain = "*.${element(var.stagiaires_names, count.index)}.${var.formation_subdomain}"
  fieldtype = "A"
  ttl       = "0"
  target    = element(var.vnc_stagiaires_public_ips, count.index)
}

resource "ovh_domain_zone_record" "formateurs_wildcard_subdomains" {
  count = length(var.formateurs_names)
  zone  = data.ovh_domain_zone.doxx_domain.name
  # subdomain = element(scaleway_instance_server.vnc_servers_formateurs.*.public_ip, count.index)
  subdomain = "*.${element(var.formateurs_names, count.index)}.${var.formation_subdomain}"
  fieldtype = "A"
  ttl       = "180"
  target    = element(var.vnc_formateurs_public_ips, count.index)
}

resource "ovh_domain_zone_record" "guacamole_node_subdomain" {
  # Changing because of Let's Encrypt limit
  #   zone      = data.ovh_domain_zone.ethicaltech_domain.name
  zone = data.ovh_domain_zone.doxx_domain.name
  # zone      = data.ovh_domain_zone.hp_domain.name
  subdomain = "lab"
  # subdomain = "guacamole"
  fieldtype = "A"
  ttl       = "180"
  target    = var.guacamole_public_ip
}

