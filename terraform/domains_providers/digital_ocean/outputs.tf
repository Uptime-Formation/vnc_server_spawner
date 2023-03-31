
output "global_lab_domain" {
  value = "guacamole.${var.formation_subdomain}.${data.digitalocean_domain.domain.name}"
}