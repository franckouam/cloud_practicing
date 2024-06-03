#Configure AWS provider
provider "aws" {
  region = var.region
}

data "aws_security_group" "sg" {
  filter {
    name = "tag:Name"
    values = var.security_group_name
  }
}

data "aws_ami" "ami" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name = "name"
    values = ["ubuntu*20.04*-amd64-server-*"]
  }

}

data "aws_subnet" "public" {
  filter {
    name = "tag:Name"
    values = ["kofra-public-subnet"]
  }
}
resource "aws_instance" "terraform_instance" {
  ami = data.aws_ami.ami.id
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids = [data.aws_security_group.sg.id]
  subnet_id = data.aws_subnet.public.id
  associate_public_ip_address = true
  source_dest_check = false
  tags = {
    Name = var.instance_name
  }
}
