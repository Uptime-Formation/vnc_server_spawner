variable "stagiaires_names" {
  default = [
    "stagiaire1",
    "stagiaire2",
  ]
}

variable "formateurs_names" {
  default = [
    "elie",
  ]
}

variable "formation_subdomain" {
  default = "debugg"
}

variable "global_lab_domain" {
  default = "eliegavoty.xyz"
}

variable "hcloud_vnc_server_type" {
  default = "cx31"
}

variable "hcloud_guacamole_server_type" {
  default = "cpx21"
}