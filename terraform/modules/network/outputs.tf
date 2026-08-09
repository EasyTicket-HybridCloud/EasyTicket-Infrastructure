output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_azs" {
  description = "The availability zones of the VPC"
  value       = module.vpc.azs
}

output "public_subnets" {
  description = "The public subnets of the VPC"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "The private subnets of the VPC"
  value       = module.vpc.private_subnets
}

output "database_subnets" {
  description = "The database subnets of the VPC"
  value       = module.vpc.database_subnets
}

output "database_subnet_group_name" {
  description = "The name of the database subnet group"
  value       = module.vpc.database_subnet_group_name
}