
variable "digitalocean_token" {}

provider "digitalocean" {
  token = var.digitalocean_token
}

data "digitalocean_domain" "dopluk_domain" {
  name = "dopl.uk"
}

resource "digitalocean_record" "vnc_node_subdomains" {
  count = length(local.vnc_servers)
  domain = data.digitalocean_domain.dopluk_domain.name
  type   = "A"
  name   = element(local.vnc_servers, count.index)
  value  = element(hcloud_server.vnc_servers.*.ipv4_address, count.index)
}
