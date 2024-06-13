variable "region" {
  type = string
}
variable "image_name" {
  type = list
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
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

variable "i_frontend_name" {
  type = string
}

variable "i_streamer_name" {
  type = string
}

variable "sg_frontend_name" {
  type = string
}

variable "sg_streamer_name" {
  type = string
}

variable "internet_gw_name" {
  type = string
}


variable "route_table_name" {
  type = string
}


variable "frontend_sg_name" {
  type = string
}

variable "streamer_sg_name" {
  type = string
}

variable "dns_name" {
  type = string
}