variable "stagiaires_names" {
  default = [
    "dorval",
    "leguillou",
    "jarrige",
    "gaultier",
    "gautier",
    "rhalmi",
    "stagiaire1",
  ]
}

variable "formateurs_names" {
  default = [
    "elie",
  ]
}

variable "formation_subdomain" {
  default = "formation"
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