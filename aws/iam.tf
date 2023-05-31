# TODO: IAM permissions for EBS persistence

resource "aws_iam_role" "opw" {
  name = "opw"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "opw" {
  role = aws_iam_role.opw.name
  name = "opw"
}

# We include SSM support to login to OPW instances spawned via this manifest.
resource "aws_iam_role_policy_attachment" "opw" {
  role       = aws_iam_role.opw.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
