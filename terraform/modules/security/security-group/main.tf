module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 6.0"

  vpc_id      = var.vpc_id
  name        = var.name
  description = "Security group for ${var.name}"

  ingress_rules = var.ingress
  egress_rules  = var.egress

  tags = var.tags
}