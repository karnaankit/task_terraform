module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.1"

  name = "ankit-vpc"
  cidr = "10.30.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.30.0.0/24", "10.30.1.0/24", "10.30.2.0/24"]
  private_subnets = ["10.30.128.0/24", "10.30.129.0/24", "10.30.130.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true
  enable_vpn_gateway = false
}
