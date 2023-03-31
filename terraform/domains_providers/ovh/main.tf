
terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "0.29.0"
    }
  }
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
  subdomain = "${element(var.stagiaires_names, count.index)}.lab"
  fieldtype = "A"
  ttl       = "180"
  target    = element(var.vnc_stagiaires_public_ips, count.index)
}

resource "ovh_domain_zone_record" "formateurs_subdomains" {
  count = length(var.stagiaires_names)
  zone  = data.ovh_domain_zone.doxx_domain.name
  # subdomain = element(scaleway_instance_server.vnc_servers.*.public_ip, count.index)
  subdomain = "${element(var.formateurs_names, count.index)}.lab"
  fieldtype = "A"
  ttl       = "180"
  target    = element(var.vnc_formateurs_public_ips, count.index)
}

resource "ovh_domain_zone_record" "guacamole_node_subdomain" {
  zone      = data.ovh_domain_zone.doxx_domain.name
  subdomain = "guacamole"
  fieldtype = "A"
  ttl       = "180"
  target    = var.guacamole_public_ip
}
