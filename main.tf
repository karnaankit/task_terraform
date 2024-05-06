module "vpc" {
  source = "./modules/services/vpc"
}

module "s3" {
  source = "./modules/services/s3"
}

module "cloudfront" {
  source = "./modules/services/cloudfront"
  depends_on = [module.s3]
}

module "bastion" {
  source = "./modules/services/bastion"
  private_subnets = module.vpc.private_subnets
}

module "rds" {
  source = "./modules/services/rds"
  private_subnets = module.vpc.private_subnets
}

module "asg" {
  source = "./modules/services/asg"
  private_subnets = module.vpc.private_subnets
}

module "alb" {
  source = "./modules/services/alb"
  private_subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id
}