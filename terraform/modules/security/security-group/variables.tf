variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "ingress" {
  description = "Map of ingress rules"
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    ip_protocol = string

    cidr_ipv4                    = optional(string)
    referenced_security_group_id = optional(string)
  }))
  default = {}
}

variable "egress" {
  description = "Map of egress rules"
  type = map(object({
    description = string
    from_port   = number
    to_port     = number
    ip_protocol = string
    cidr_ipv4   = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}
}
