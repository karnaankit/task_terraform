module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 7.0"

  name                      = "ankit-asg"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.private_subnets

  launch_template_name   = "ankit-asg"
  update_default_version = true

  image_id          = "ami-057f57c2fcd14e5f4" # ECS optimized AMI
  instance_type     = "t2.micro"
  ebs_optimized     = true
  enable_monitoring = true

  user_data = base64encode(<<USERDATA
  #!/bin/bash
  echo "ECS_CLUSTER=CLUSTER_NAME" >> /etc/ecs/ecs.config
  USERDATA
  )

  create_iam_instance_profile = true
  iam_role_name               = "ankit-asg"
  iam_role_policies = {
    Task_role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    Task_execution_role = aws_iam_role.role.arn
  }

  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 25
        volume_type           = "gp3"
      }
    }
  ]
}

resource "aws_iam_role" "role" {
  name = "ec2_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#   name = "my-asg"
#   desired_capacity = 3
#   max_size         = 3
#   min_size         = 1
#
#   launch_template = aws_launch_template.lt.id
#   vpc_zone_identifier = var.private_subnets
#   health_check_type   = "EC2"
#   use_lt = true

# resource "aws_iam_role" "role" {
#   name = "ec2_role"
#
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }
#
# resource "aws_iam_role_policy_attachment" "ecs_policy" {
#   role       = aws_iam_role.role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
# }
#
# resource "aws_iam_instance_profile" "profile" {
#   name = "ec2_profile"
#   role = aws_iam_role.role.name
# }
#
# resource "aws_launch_template" "lt" {
#   image_id      = "ami-057f57c2fcd14e5f4" // ECS optimized AMI
#   instance_type = "t2.micro"
#   iam_instance_profile {
#     name = aws_iam_instance_profile.profile.name
#   }
#   user_data = base64encode(<<USERDATA
#   #!/bin/bash
#   echo "ECS_CLUSTER=CLUSTER_NAME" >> /etc/ecs/ecs.config
#   USERDATA
#   )
# }