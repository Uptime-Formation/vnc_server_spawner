variable "stagiaires" {
  default = [{
    name= "demo", # keep this to show the world the power of guacamole
    password="devops101"
  }]
}

variable "formateurs" {
  default = [{
    name= "hadrien",
    password="devops202"
  }]
}