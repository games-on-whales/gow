terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region = var.aws-region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["099720109477"]
  # Canonical

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-${var.ubuntu-version}-amd64-server-*"]
  }
}

resource "aws_instance" "aws_instance" {

  ami = data.aws_ami.amazon_linux.id
  key_name = var.ssh-key-name
  instance_type = var.instance-type

  security_groups = [aws_security_group.sg.name]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.instance.name

  tags = {
    Name = var.project-name
  }

  root_block_device {
    volume_size = var.volume-size
  }

  user_data_base64 = data.template_cloudinit_config.config.rendered

  //  connection {
  //    host = self.public_ip
  //    type = "ssh"
  //    agent = false
  //    private_key = file("~/.ssh/gow-tf-key.pem")
  //    user = "ubuntu"
  //  }
  //
  //  provisioner "file" {
  //    source = "../docker-compose.yml"
  //    destination = "/tmp/gow/docker-compose.yml"
  //  }
  //
  //  provisioner "file" {
  //    source = "../.env"
  //    destination = "/tmp/gow/.env"
  //  }
  //
  //  provisioner "remote-exec" {
  //    inline = [
  //      "sh cd /tmp/gow && docker-compose pull",
  //      "sh cd /tmp/gow && docker-compose up -d",
  //    ]
  //  }
}
