# Configure the AWS Provider
provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

# data "aws_ami" "redhat" {
#   most_recent      = true
#   # name_regex       = "^myami-\\d{3}"
#   owners           = ["aws-marketplace"]
#
#   filter {
#     name   = "name"
#     values = ["Red Hat Enterprise Linux*"]
#   }
# }

data "aws_ami" "centos" {
owners      = ["679593333241"]
most_recent = true

  filter {
      name   = "name"
      values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }

  filter {
      name   = "architecture"
      values = ["x86_64"]
  }
  filter {
      name   = "root-device-type"
      values = ["ebs"]
  }
}

data "aws_ami" "amazon_linux_ami"{
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "image-id"
    values = ["ami-08f3d892de259504d"]
  }
}

resource "aws_security_group" "docker_allow_http_ssh" {
  name        = "docker_allow_http_ssh"
  description = "Allow HTTP and SSH  inbound traffic"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docker_allow_http_ssh"
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "docker_instance_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDiemqrsA8plndBEbh4dk5wOjNTaJrUXCaW2mwd46uZxzylXjYteZxYVEGNze8ouuIYqmoIRDpXxrzmf74snMkv/Wjju1daWOTmHmhIaD1AHBLFJomdooKkWRMN60opYB6GWujOx0PF1wpLaE8+CzWDO2qXAyTs3Kofph2m/GJDtSznBBMuMnxH+eA3iwzD4BGM/2gipHTWQKgkN3t5IxsDim8T/t8nbnk7xvbtArYAJ0bZxMCODkdQ7iSnqo1/gbM5H3cEBfaF6pmtVWRdZ8HElvQf5voMQBWgPkIdgJSxVaqw4Z5NhaWwxWJgjYP2t8EJGoXuy4rNoHRYBXlT6wyN thsubramani@MB-THSUBRAMAN.lan"
}

resource "aws_instance" "docker_instance" {
  ami           = data.aws_ami.amazon_linux_ami.id
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.docker_allow_http_ssh.name}"]
  key_name = "docker_instance_key"

  tags = {
    Name = "docker Daemon"
  }
}

output "instance_ips" {
  value = ["${aws_instance.docker_instance.public_ip}"]
}
