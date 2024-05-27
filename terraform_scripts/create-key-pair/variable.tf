variable "region" {
  type = string
}
variable "vpc_name" {
  type = list
}
variable "cidr_block" {
  type = string
}
variable "subnet_name" {
  type = list
}

variable "key_name" {
  type = string
}

variable "algorithm" {
  type = string
}

variable "rsa_bits" {
  type = number
}
