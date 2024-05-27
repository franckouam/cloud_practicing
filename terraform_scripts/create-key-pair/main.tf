#Configure AWS provider
provider "aws" {
  region = var.region
}

resource "tls_private_key" "private_tls" {
  algorithm = var.algorithm
  rsa_bits = var.rsa_bits
}

#Define key pair resource
resource "aws_key_pair" "key_pair" {
  key_name = var.key_name
  public_key = tls_private_key.private_tls.public_key_openssh
}
