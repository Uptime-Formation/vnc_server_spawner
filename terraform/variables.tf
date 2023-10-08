variable "stagiaires_names" {
  type = list(string)
}

variable "formateurs_names" {
  type = list(string)
}

variable "formation_subdomain" {
  type = string
}

variable "global_lab_domain" {
  # default = "eliegavoty.xyz"
  type = string
}

variable "ssh_key_content" {
  type = string
}

# Domain providers::OVH
variable "ovh_application_key" {
  type    = string
}
variable "ovh_application_secret" {
  type    = string
}
variable "ovh_consumer_key" {
  type    = string
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
variable "scaleway_image_name" {
  type = string
  default = "ubuntu-focal"
}
variable "scaleway_image_id" {
  type = string
  default = ""
}
variable "scaleway_vnc_server_type" {
  type    = string
  default = "DEV1-L"
}
variable "scaleway_guacamole_server_type" {
  default = "DEV1-L"
  type    = string
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
  default = "cpx21"
  type    = string
}
variable "hcloud_image_name" {
  type = string
  default = "ubuntu-22.04"
}
variable "hcloud_image_id" {
  type = string
  default = ""
}