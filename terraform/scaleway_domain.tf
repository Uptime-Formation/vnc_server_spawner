
variable "scaleway_token" {}

provider "scaleway" {
  # token = var.scaleway_token
  # token = var.scaleway_api_access_key
  token = var.scaleway_api_secret_key 
  # token = var.scaleway_orga_id
}

data "scaleway_domain" "doxx_domain" {
  name = "lab.doxx.fr"
}

resource "scaleway_record" "vnc_node_subdomains" {
  count = length(local.vnc_servers)
  domain = data.scaleway_domain.doxx_domain.name
  type   = "A"
  name   = element(local.vnc_servers, count.index)
  value  = element(scaleway_instance_server.vnc_servers.*.ipv4_address, count.index)
}

resource "scaleway_record" "guacamole_node_subdomain" {
  domain = data.scaleway_domain.doxx_domain.name
  type   = "A"
  name   = "guacamole"
  value  = scaleway_instance_server.guacamole_server.ipv4_address
}