variable "region" {
  type = string
}
variable "image_name" {
  type = list
}

variable "instance_name" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "security_group_name" {
  type = list
}

variable "vpc_name" {
  type = list
}
variable "cidr_block_public" {
  type = string
}
variable "cidr_block_private" {
  type = string
}
variable "subnet_public" {
  type = string
}
variable "subnet_private" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "algorithm" {
  type = string
}

variable "rsa_bits" {
  type = number
}

