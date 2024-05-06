resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.30.0.0/16"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.30.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "6.4.0"

  name    = "ankit-alb"
  load_balancer_type = "application"
  vpc_id  = var.vpc_id
  subnets = var.private_subnets
  security_groups = [aws_security_group.alb_sg.id]
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = "arn:aws:iam::123456789012:server-certificate/test_cert-123456789012"
      target_group_index = 0
    }
  ]
  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]
  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTPS"
      backend_port     = 443
      target_type      = "instance"
    }
  ]
}