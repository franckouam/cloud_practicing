#Configure AWS provider
provider "aws" {
  region = var.region
}

#Reading vpc resource
data "aws_vpc" "this" {
  filter {
    name = "tag:Name"
    values = var.vpc_name
  }
}

#Read a subnet resource
data "aws_subnet" "public" {
  filter {
    name = "tag:Name"
    values = var.subnet_name
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "kofra-ssh-security-group"
  description = "Allow SSH inbound  and outbound traffic"
  vpc_id      = data.aws_vpc.this.id

  tags = {
    Name = "kofra_allow_ssh"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_in" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = data.aws_vpc.this.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_out" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "-1"
  to_port           = -1
}
