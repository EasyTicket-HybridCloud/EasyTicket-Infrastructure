# Dev Environment

## Purpose

Đây là root module Terraform cho environment **development** — nơi để
provision/thử nghiệm hạ tầng trước khi đưa lên `staging`/`production`.
Environment này compose các module trong [`../../modules`](../../modules)
và cấu hình theo giá trị dành riêng cho dev, không chứa logic tạo resource
trực tiếp (theo nguyên tắc ở [`terraform/README.md`](../../README.md)).

## Current state

- `provider "aws"` được cấu hình theo `var.aws_region`.
- Đã compose module [`network`](../../modules/network/README.md) để tạo VPC
  (`module.vpc`) cùng public/private/database subnet.
- `data.tf` khai báo `data.aws_ami.amazon_linux` — AMI Amazon Linux dùng cho
  compute sau này (hiện chưa có module compute nào tham chiếu tới data source
  này).
- `outputs.tf` và `terraform.tfvars` hiện đang **trống** — cần bổ sung giá trị
  thực tế trước khi `apply`.

## Usage

```bash
cd terraform/environments/dev

terraform init
terraform plan
terraform apply
```

Trước khi `plan`/`apply`, cần điền giá trị cho các biến bắt buộc trong
`terraform.tfvars` (xem `variables.tf`), ví dụ:

```hcl
aws_region = "ap-southeast-1"

vpc_cidr = "10.10.0.0/16"
vpc_azs  = ["ap-southeast-1a", "ap-southeast-1b"]

public_subnets   = ["10.10.0.0/24", "10.10.1.0/24"]
private_subnets  = ["10.10.10.0/24", "10.10.11.0/24"]
database_subnets = ["10.10.20.0/24", "10.10.21.0/24"]
```

## Notes

- `dev` là environment ít quan trọng nhất, phù hợp để thử nghiệm module mới
  trước khi áp dụng cho `staging`/`production`.
- Khi thêm module mới (compute, cache, load-balancer...), compose trực tiếp
  trong `main.tf` theo pattern hiện có của `module "vpc"`, không copy code từ
  module sang.
- Nhớ chạy `terraform fmt -recursive` và `terraform validate` trước khi tạo
  Pull Request (xem mục "Local Development" trong README gốc).
