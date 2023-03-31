
output "global_lab_domain" {
  value = "guacamole.${data.ovh_domain_zone.doxx_domain.name}"
}