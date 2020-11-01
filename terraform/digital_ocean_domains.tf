
variable "digitalocean_token" {}

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
  value  = element(module.servers.vnc_stagiaires_public_ips, count.index)
}

resource "digitalocean_record" "formateurs_subdomains" {
  count = length(var.formateurs_names)
  domain = data.digitalocean_domain.dopluk_domain.name
  type   = "A"
  name   = element(var.formateurs_names, count.index)
  value  = element(module.servers.vnc_stagiaires_public_ips, count.index)
}

resource "digitalocean_record" "guacamole_node_subdomain" {
  domain = data.digitalocean_domain.dopluk_domain.name
  type   = "A"
  name   = "guacamole"
  value  = module.servers.guacamole_public_ip
}