#Configure aws provider
provider "aws" {
  region = var.region
}

#Read vpc resource 
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = var.vpc_name
  }
}

#Create a subnet
resource "aws_subnet" "public" {
  vpc_id     = data.aws_vpc.this.id
  cidr_block = var.cidr_block_public
  availability_zone = "${var.region}a"

  tags = {
    Name = var.subnet_public
  }
}

#Create a subnet
resource "aws_subnet" "private" {
  vpc_id     = data.aws_vpc.this.id
  cidr_block = var.cidr_block_private
  availability_zone = "${var.region}b"
  tags = {
    Name = var.subnet_private
  }
}


#Capture vpc_id in output variable
output "vpc_id" {
  value = data.aws_vpc.this.id
}

#Capture vpc_cidr_block in output variable
output "vpc_cidr_block" {
  value = data.aws_vpc.this.cidr_block
}

#Creating an internet gateway
resource "aws_internet_gateway" "kofra_gw" {
  vpc_id = data.aws_vpc.this.id
  tags = {
    Name = "kofra-internet-gw"
  }
}

#Creating a routing table
resource "aws_route_table" "route_table" {
  vpc_id = data.aws_vpc.this.id
  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.kofra_gw.id
  }
  tags = {
    Name = "kofra-route-table"
  }

}

#Adding an association for the created routing table
resource "aws_route_table_association" "route_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_table.id
}

#Creating a security group
resource "aws_security_group" "web_server_security_group" {
  name        = "kofra-ssh-security-group"
  description = "Allow SSH inbound  and outbound traffic"
  vpc_id      = data.aws_vpc.this.id

  tags = {
    Name = "kofra_allow_ssh"
  }
}

#Adding rules for the incoming traffic
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_in" {
  security_group_id = aws_security_group.web_server_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

#Adding rules for the outgoing traffic
resource "aws_vpc_security_group_egress_rule" "allow_ssh_out" {
  security_group_id = aws_security_group.web_server_security_group.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = -1
  ip_protocol       = "-1"
  to_port           = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_in" {
  security_group_id = aws_security_group.web_server_security_group.id
  cidr_ipv4	    = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port	    = 80
  to_port	    = 80
}
#Creating a TLS private key
resource "tls_private_key" "pk" {
  algorithm = var.algorithm
  rsa_bits = var.rsa_bits
}

#Define key pair resource
resource "aws_key_pair" "key_pair" {
  key_name = var.key_name
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "kofra_key.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ~/kofra_key.pem && chmod 0600 ~/kofra_key.pem"
  }
}

#Fetching the image ID
data "aws_ami" "ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu*20.04*-amd64-server-*"]
  }

}

#Creating an AWS EC2 instance
resource "aws_instance" "kofra_instance" {
  ami = data.aws_ami.ami.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.web_server_security_group.id]
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true
  source_dest_check = false
  tags = {
    Name = var.instance_name
  }
}

resource "aws_route53_zone" "gintonic" {
  name = "gintonic-telecom.net"
}

resource "aws_route53_record" "kofra" {
  zone_id = aws_route53_zone.gintonic.zone_id
  name    = "kofra"
  type    = "A"
  ttl     = 300
  records = [aws_instance.kofra_instance.public_ip]
}


output "instance_public_ip" {
    description = "Public IP address of the EC2 instance"  
    value       = aws_instance.app_server.public_ip
}

# TODO: Modify the script in order to create 2 EC2 instances