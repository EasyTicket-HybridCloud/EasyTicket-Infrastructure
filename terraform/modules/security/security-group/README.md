# Security Group Module

## Purpose

Tạo một AWS Security Group cùng các rule ingress/egress, dùng để kiểm soát
traffic ra/vào cho các resource trong VPC (EC2, RDS, ALB...).

Module này wrap lại module chính thức
[`terraform-aws-modules/security-group/aws`](https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws)
(`~> 6.0`).

## Features

- Tạo một security group gắn với `vpc_id` chỉ định.
- Định nghĩa nhiều ingress rule dưới dạng map (`ingress`).
- Định nghĩa nhiều egress rule dưới dạng map (`egress`).
- Description của security group tự sinh theo `name`.
- Cho phép gắn tag tùy ý qua `tags`.

## Usage

```hcl
module "web_sg" {
  source = "../../modules/security/security-group"

  vpc_id = module.vpc.vpc_id
  name   = "easyticket-dev-web-sg"

  ingress = {
    http = {
      description = "Allow HTTP from internet"
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      description = "Allow HTTPS from internet"
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  egress = {
    all_outbound = {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name       | Type          | Required | Default | Description                                    |
| ---------- | ------------- | -------- | ------- | ----------------------------------------------- |
| `vpc_id`   | `string`      | yes      | -       | ID của VPC chứa security group                  |
| `name`     | `string`      | yes      | -       | Tên security group                              |
| `ingress`  | `map(object)` | no       | `{}`    | Map các ingress rule (xem cấu trúc bên dưới)    |
| `egress`   | `map(object)` | no       | `{}`    | Map các egress rule (xem cấu trúc bên dưới)     |
| `tags`     | `map(string)` | no       | `{}`    | Tag áp dụng cho security group                  |

Cấu trúc mỗi phần tử trong `ingress`:

```hcl
{
  description                   = string
  from_port                     = number
  to_port                       = number
  ip_protocol                   = string
  cidr_ipv4                     = optional(string)
  referenced_security_group_id  = optional(string)
}
```

Chỉ cần chọn một trong hai: `cidr_ipv4` (theo IP) hoặc
`referenced_security_group_id` (theo security group khác).

Cấu trúc mỗi phần tử trong `egress`:

```hcl
{
  description = string
  from_port   = number
  to_port     = number
  ip_protocol = string
  cidr_ipv4   = string
}
```

## Outputs

| Name     | Description                     |
| -------- | -------------------------------- |
| `id`     | ID của security group            |
| `arn`    | ARN của security group           |
| `vpc_id` | VPC ID mà security group thuộc về|

## Notes

- README này mô tả đúng theo code hiện tại. Nếu cần hỗ trợ thêm dạng rule
  khác (ví dụ egress theo `referenced_security_group_id`), hãy sửa
  `variables.tf`/`main.tf` rồi cập nhật lại tài liệu.
