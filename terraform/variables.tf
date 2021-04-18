variable "stagiaires" {
  default = [
    {
    name= "mohammed", 
    password="devops101"
  },
    {
    name= "renan", 
    password="devops101"
  },
    {
    name= "weibin", 
    password="devops101"
  },
    {
    name= "william", 
    password="devops101"
  },
    {
    name= "youssef", 
    password="devops101"
  },
    {
    name= "brandon", 
    password="devops101"
  },
    {
    name= "julien", 
    password="devops101"
  },
    {
    name= "vincent", 
    password="devops101"
  }
  ]
}

variable "formateurs" {
  default = [
    {
    name= "hadrien",
    password="devops202"
  },
  ]
}

variable "scaleway_vnc_servers_size" {
  default = "DEV1-L"
}

variable "scaleway_guac_servers_size" {
  default = "DEV1-L"
}