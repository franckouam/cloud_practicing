#Configure AWS provider
provider "aws" {
  region = var.region
}

resource "tls_private_key" "pk" {
  algorithm = var.algorithm
  rsa_bits = var.rsa_bits
}

#Define key pair resource
resource "aws_key_pair" "key_pair" {
  key_name = var.key_name
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "kofra_key.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ~/kofra_key.pem"
  }
}
