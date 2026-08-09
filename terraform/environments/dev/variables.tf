variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_azs" {
  description = "List of availability zones for the VPC"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "database_subnets" {
  description = "List of database subnet CIDR blocks"
  type        = list(string)
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "The name of the key pair to use for the EC2 instances"
  type        = string
  default     = null
}

variable "database_subnet_group_name" {
  description = "The name of the database subnet group"
  type        = string
  default     = null
}