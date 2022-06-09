variable "aws-region" {
  default = "eu-west-2"
}

variable "instance-type" {
  # g3s.xlarge == Lowest Nvidia capable instance
  default = "g3s.xlarge"
}

variable "ubuntu-version" {
  # Seems that 20.04 is the last version that supports nvidia-docker
  # see: https://nvidia.github.io/nvidia-docker/
  default = "20.04"
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