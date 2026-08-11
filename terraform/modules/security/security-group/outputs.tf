output "id" {
  description = "The ID of the security group"
  value       = module.sg.id
}

output "arn" {
  description = "The ARN of the security group"
  value       = module.sg.arn
}

output "vpc_id" {
  description = "The VPC ID of the security group"
  value       = module.sg.vpc_id
}
