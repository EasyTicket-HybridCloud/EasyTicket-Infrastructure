# Staging Environment

## Purpose

Đây là root module Terraform cho environment **staging** — môi trường dùng
để kiểm thử trước khi lên `production`, cấu hình nên mô phỏng gần giống
production nhất có thể (nhưng có thể scale nhỏ hơn để tiết kiệm chi phí).
Environment này compose các module trong [`../../modules`](../../modules)
và cấu hình theo giá trị dành riêng cho staging, không chứa logic tạo
resource trực tiếp (theo nguyên tắc ở [`terraform/README.md`](../../README.md)).

## Current state

`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` của environment này
hiện đang **trống hoàn toàn** — chưa có resource/module nào được compose.

## Usage (khi bắt đầu triển khai)

1. Khai báo `terraform` block và `required_providers` trong `versions.tf`
   (tham khảo [`../dev/versions.tf`](../dev/versions.tf)).
2. Khai báo `provider "aws"` trong `main.tf`.
3. Compose các module cần thiết, ví dụ:

```hcl
provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Environment = "staging"
    Project     = "easyticket"
  }
}

module "vpc" {
  source = "../../modules/network"

  vpc_name = "easyticket-staging-vpc"
  vpc_cidr = var.vpc_cidr
  vpc_azs  = var.vpc_azs

  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  vpc_tags = local.common_tags
}
```

4. Khai báo biến tương ứng trong `variables.tf` và tạo `terraform.tfvars`
   (không commit nếu chứa secret).
5. Chạy:

```bash
cd terraform/environments/staging

terraform init
terraform plan
terraform apply
```

## Notes

- Không copy nguyên `main.tf` của `dev` sang — chỉ copy cấu trúc rồi chỉnh
  lại configuration (CIDR, tag, kích thước resource...) cho phù hợp staging.
- State của `staging` phải tách biệt hoàn toàn với `dev`/`production`.
- Trước khi tạo Pull Request, chạy `terraform fmt -recursive` và
  `terraform validate`.
