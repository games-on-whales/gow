variable "aws-region" {
  default = "eu-west-2"
}

variable "instance-type" {
  # Testing out a small image first
  default = "t3.micro"
}

variable "ssh-key-name" {
  default = "gow-tf-key"
}

variable "project-name" {
  default = "gow-tf-aws"
}

variable "volume-size" {
  default = 20
}

variable "instance-profile-policy-arns" {
  description = "A list of IAM policy ARNs to be associated to the instance profile"
  type = list(string)
  default = []
}

data "http" "my_public_ip" {
  url = "https://ipinfo.io/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  local_ip = jsondecode(data.http.my_public_ip.body).ip
}