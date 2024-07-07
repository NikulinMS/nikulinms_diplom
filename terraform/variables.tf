variable "yc_id" {
  default = "b1g8dolaql3are1tu770"
}

variable "yf_id" {
  default = "b1gjh7prfs9fus38l32u"
}

variable "OS" {
  default = "fd8l04iucc4vsh00rkb1"
}

variable "subnet-zones" {
  type = list(string)
  default = [ "ru-central1-a", "ru-central1-b", "ru-central1-d" ]
}

variable "cidr" {
  type = map(list(string))
  default = {
    "cidr" = [ "10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24" ]
  }
}

