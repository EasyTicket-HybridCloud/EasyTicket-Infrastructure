variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "vpc_azs" {
  description = "The availability zones for the VPC"
  type        = list(string)
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

variable "database_subnet_group_name" {
  description = "The name of the database subnet group to associate with the RDS instance"
  type        = string
  default     = null
}

variable "vpc_tags" {
  description = "Tags to apply to the VPC and its resources"
  type        = map(string)
  default     = {}
}
