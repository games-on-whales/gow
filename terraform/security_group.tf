resource "aws_security_group" "sg" {
  name = var.project-name
}

resource "aws_security_group_rule" "ssh_in" {
  type = "ingress"
  protocol = "tcp"
  security_group_id = aws_security_group.sg.id
  from_port = 22
  to_port = 22
  cidr_blocks = ["${local.local_ip}/32"]
}

resource "aws_security_group_rule" "in_sunshine_1" {
  type = "ingress"
  protocol = "tcp"
  security_group_id = aws_security_group.sg.id
  from_port = 47984
  to_port = 47990
  cidr_blocks = ["${local.local_ip}/32"]
}

resource "aws_security_group_rule" "in_sunshine_2" {
  type = "ingress"
  protocol = "tcp"
  security_group_id = aws_security_group.sg.id
  from_port = 48010
  to_port = 48010
  cidr_blocks = ["${local.local_ip}/32"]
}

resource "aws_security_group_rule" "in_sunshine_3" {
  type = "ingress"
  protocol = "udp"
  security_group_id = aws_security_group.sg.id
  from_port = 48010
  to_port = 48010
  cidr_blocks = ["${local.local_ip}/32"]
}

resource "aws_security_group_rule" "in_sunshine_4" {
  type = "ingress"
  protocol = "udp"
  security_group_id = aws_security_group.sg.id
  from_port = 47998
  to_port = 48000
  cidr_blocks = ["${local.local_ip}/32"]
}

resource "aws_security_group_rule" "out_all" {
  type = "egress"
  protocol = -1
  security_group_id = aws_security_group.sg.id
  from_port = 0
  to_port = 0
  cidr_blocks = ["0.0.0.0/0"]
}