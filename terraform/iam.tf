resource "aws_iam_role_policy_attachment" "instance" {
  for_each = toset(var.instance-profile-policy-arns)

  policy_arn = each.key
  role = aws_iam_role.instance.id
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name = "${var.project-name}-instance-profile"
  force_detach_policies = true
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
}

resource "aws_iam_instance_profile" "instance" {
  name = var.project-name
  role = aws_iam_role.instance.name
}