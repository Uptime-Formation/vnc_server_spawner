variable "stagiaires_names" {
  type = list(string)
}

variable "formateurs_names" {
  type = list(string)
}

variable "formation_subdomain" {
  type = string
}

variable "servers_provider" {
  type    = string
  default = "scaleway"
}

# Domain providers::OVH
variable "ovh_application_key" {
  type    = string
  default = "changeme"
}
variable "ovh_application_secret" {
  type    = string
  default = "changeme"
}
variable "ovh_consumer_key" {
  type    = string
  default = "changeme"
}


# Domain providers::digitalocean
variable "digitalocean_token" {
  type    = string
  default = "changeme"
}


# Server providers::Scaleway
variable "scaleway_api_secret_key" {
  type    = string
  default = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
}
variable "scaleway_api_access_key" {
  type    = string
  default = "SCW00000000000000000"
}
variable "scaleway_orga_id" {
  type    = string
  default = "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
}

# Server providers::hertzner
variable "hcloud_token" {
  type    = string
  default = "changeme"
}
variable "hcloud_vnc_server_type" {
  type    = string
  default = "cx31"
}
variable "hcloud_guacamole_server_type" {
  type    = string
  default = "cx11"
}