variable "stagiaires_names" {
  default = [
    "stagiaire1",
    "stagiaire2",
    "stagiaire3",
    "stagiaire4",
    "stagiaire5",
    "stagiaire6",
    "stagiaire7",
    "stagiaire8",
    "stagiaire9",
    "stagiaire10",
    "stagiaire11",
    "stagiaire12",
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

variable "hcloud_vnc_server_type" {
  default = "cx31"
}

variable "hcloud_guacamole_server_type" {
  default = "cx11"
}