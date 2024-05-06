resource "aws_iam_role" "ssm_role" {
  name = "ssm_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "bastion_host" {
  ami           = "ami-0a9d27a9f4f5c0efc"
  instance_type = "t2.micro"
  subnet_id     = var.private_subnets[1]

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  tags = {
    Name = "Bastion Host"
  }
}
