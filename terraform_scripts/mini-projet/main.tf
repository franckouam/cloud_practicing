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

#Create a public subnet
resource "aws_subnet" "public" {
  vpc_id     = data.aws_vpc.this.id
  cidr_block = var.cidr_block_public
  availability_zone = "${var.region}a"

  tags = {
    Name = var.subnet_public
  }
}

#Create a private subnet
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
resource "aws_internet_gateway" "kmh_gw" {
  vpc_id = data.aws_vpc.this.id
  tags = {
    Name = "kmh-internet-gw"
  }
}

#Creating a routing table
resource "aws_route_table" "route_table" {
  vpc_id = data.aws_vpc.this.id
  route {
    cidr_block = var.cidr_block
    gateway_id = aws_internet_gateway.kmh_gw.id
  }
  tags = {
    Name = "kmh-route-table"
  }

}

#Adding associations for the created routing table
resource "aws_route_table_association" "route_public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "route_private_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.route_table.id
}

#Creating a security group for frontend
resource "aws_security_group" "frontend_security_group" {
  name        = var.sg_frontend_name
  description = "Allow SSH and HTTPS inbound  and outbound traffic"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    cidr_blocks         = ["0.0.0.0/0"]
    from_port         = 22
    ip_protocol       = "tcp"
    to_port           = 22
  }

  ingress {
    cidr_blocks         = ["0.0.0.0/0"]
    from_port         = 443
    ip_protocol       = "tcp"
    to_port           = 443
  }

  ingress {
    cidr_blocks         = ["0.0.0.0/0"]
    from_port         = 80
    ip_protocol       = "tcp"
    to_port           = 80
  }

  egress {
    cidr_blocks         = ["0.0.0.0/0"]
    from_port         = -1
    ip_protocol       = "-1"
    to_port           = -1
  }

  tags = {
    Name = "sg_frontend"
  }
}

#Creating a security group for streamer
resource "aws_security_group" "streamer_security_group" {
  name        = var.sg_streamer_name
  description = "Allow RTMP inbound  and outbound traffic"
  vpc_id      = data.aws_vpc.this.id

  ingress {
    cidr_ipv4         = var.cidr_block_private
    from_port         = 1935
    ip_protocol       = "tcp"
    to_port           = 1935
  }

  egress {
    cidr_ipv4         = var.cidr_block_private
    from_port         = -1
    ip_protocol       = "-1"
    to_port           = -1
  }

  tags = {
    Name = "sg_streamer"
  }
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

  provisioner "local-exec" { # Create "kmh_key.pem" to your computer
    command = "echo '${tls_private_key.pk.private_key_pem}' > ~/kmh_key.pem && chmod 0600 ~/kmh_key.pem"
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


resource "aws_instance" "servers" {
  count = 2
  key_name = var.key_name
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  
  subnet_id = element([aws_subnet.public.id, aws_subnet.private.id], count.index)

  tags = {
    Name = element([var.i_frontend_name, var.i_streamer_name], count.index)
  }
}

resource "aws_route53_zone" "intuitivesoft" {
  name = "devops.intuitivesoft.cloud"
}

resource "aws_route53_record" "kmh" {
  zone_id = aws_route53_zone.intuitivesoft.zone_id
  name    = "kmh"
  type    = "A"
  ttl     = 300
  records = [aws_instance.kmh_instance.public_ip]
}

output "instance_public_ip" {
    description = "Public IP address of the Webserver EC2 instance"  
    value       = aws_instance.frontend.public_ip
}