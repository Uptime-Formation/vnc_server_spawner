variable "ovh_application_key" {}
variable "ovh_application_secret" {}
variable "ovh_consumer_key" {}

provider "ovh" {
  endpoint="ovh-eu"
  application_key=var.ovh_application_key
  application_secret=var.ovh_application_secret
  consumer_key=var.ovh_consumer_key

}

data "ovh_domain_zone" "doxx_domain" {
    name = "doxx.fr"
    # name = "lab.doxx.fr"
}
# variable "doxx_domain" {
#   type = string
#   description = "(optional) describe your variable"
# } "scaleway_domain" "doxx_domain" {
#   name = "lab.doxx.fr"
# }
# # resource "scaleway_instance_ip" "server_ip" {}
# resource "scaleway_instance_ip_reverse_dns" "vnc_node_subdomains" {
#   count = length(local.vnc_servers)
#   reverse = data.scaleway_domain.doxx_domain.name
#   ip_id  = element(scaleway_instance_server.vnc_servers.*.public_ip, count.index)
# }

# resource "scaleway_instance_ip_reverse_dns" "guacamole_node_subdomain" {
#   reverse   = "guacamole"
#   ip_id  = scaleway_instance_server.guacamole_server.public_ip
# }

# Add a record to a sub-domain
resource "ovh_domain_zone_record" "vnc_node_subdomains" {
    count = length(local.vnc_servers)
    zone = data.ovh_domain_zone.doxx_domain.name
    # subdomain = element(scaleway_instance_server.vnc_servers.*.public_ip, count.index)
    subdomain = "${element(local.vnc_servers, count.index)}.lab"
    fieldtype = "A"
    ttl = "3600"
    target = element(scaleway_instance_server.vnc_servers.*.public_ip, count.index)
}

resource "ovh_domain_zone_record" "guacamole_node_subdomain" {
    zone = data.ovh_domain_zone.doxx_domain.name
    subdomain = "guacamole"
    fieldtype = "A"
    ttl = "3600"
    target = scaleway_instance_server.guacamole_server.public_ip
}