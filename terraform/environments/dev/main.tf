provider "aws" {
  region = var.aws_region
}

# Replace with your project name
locals {
  common_tags = {
    Environment = "dev"
    Project     = "my_project"
  }
}


module "vpc" {
  source = "../../modules/network"

  vpc_name = "vpc"
  vpc_cidr = var.vpc_cidr
  vpc_azs  = var.vpc_azs

  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  database_subnet_group_name = var.database_subnet_group_name

  vpc_tags = merge(local.common_tags, {
    # Additional tags specific to the VPC can be added here
  })
}

