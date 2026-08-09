# Network Module

## Purpose

Tạo VPC (Virtual Private Cloud) trên AWS cùng hệ thống public/private/database
subnet, dùng để làm nền tảng network cho toàn bộ hạ tầng của một environment.

Module này wrap lại module chính thức
[`terraform-aws-modules/vpc/aws`](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws)
(`~> 6.0`) thay vì tự định nghĩa resource, nhằm tận dụng các best-practice có
sẵn (NAT Gateway, route table, DNS...).

## Features

- Tạo VPC với CIDR block tùy chỉnh.
- Tạo public subnet, private subnet, database subnet theo danh sách AZ.
- Bật sẵn NAT Gateway (`one_nat_gateway_per_az = true`) để private subnet có
  thể ra internet.
- Bật sẵn DNS hostnames/support cho VPC.
- Hỗ trợ tạo database subnet group (tùy chọn) để dùng cho RDS.
- Cho phép gắn tag tùy ý qua `vpc_tags`.

## Usage

```hcl
module "vpc" {
  source = "../../modules/network"

  vpc_name = "easyticket-dev-vpc"
  vpc_cidr = "10.10.0.0/16"
  vpc_azs  = ["ap-southeast-1a", "ap-southeast-1b"]

  public_subnets   = ["10.10.0.0/24", "10.10.1.0/24"]
  private_subnets  = ["10.10.10.0/24", "10.10.11.0/24"]
  database_subnets = ["10.10.20.0/24", "10.10.21.0/24"]

  database_subnet_group_name = "easyticket-dev-db-subnet-group"

  vpc_tags = {
    Environment = "dev"
    Project     = "easyticket"
  }
}
```

## Inputs

| Name                          | Type           | Required | Default | Description                                             |
| ----------------------------- | -------------- | -------- | ------- | --------------------------------------------------------|
| `vpc_name`                    | `string`       | yes      | -       | Tên của VPC                                              |
| `vpc_cidr`                    | `string`       | yes      | -       | CIDR block của VPC                                       |
| `vpc_azs`                     | `list(string)` | yes      | -       | Danh sách availability zone sử dụng                      |
| `public_subnets`               | `list(string)` | yes      | -       | Danh sách CIDR cho public subnet                         |
| `private_subnets`              | `list(string)` | yes      | -       | Danh sách CIDR cho private subnet                        |
| `database_subnets`             | `list(string)` | yes      | -       | Danh sách CIDR cho database subnet                       |
| `database_subnet_group_name`   | `string`       | no       | `null`  | Tên database subnet group để liên kết với RDS            |
| `vpc_tags`                     | `map(string)`  | no       | `{}`    | Tag áp dụng cho VPC và các resource con                  |

## Outputs

| Name                        | Description                          |
| --------------------------- | ------------------------------------- |
| `vpc_id`                    | ID của VPC                            |
| `vpc_cidr`                  | CIDR block của VPC                    |
| `vpc_azs`                   | Danh sách availability zone của VPC   |
| `public_subnets`            | Danh sách public subnet ID            |
| `private_subnets`           | Danh sách private subnet ID           |
| `database_subnets`          | Danh sách database subnet ID          |
| `database_subnet_group_name`| Tên database subnet group             |

## Notes

- `one_nat_gateway_per_az = true` tạo một NAT Gateway cho mỗi AZ — tốn chi phí
  hơn nhưng an toàn hơn (không single point of failure). Với environment
  `dev`/`staging`, có thể cân nhắc sửa lại module để dùng một NAT Gateway
  chung nếu muốn tiết kiệm chi phí.
- Đây là tài liệu mô tả theo đúng code hiện tại của module. Nếu logic hoặc
  input/output thay đổi, hãy cập nhật lại README này cho khớp.
