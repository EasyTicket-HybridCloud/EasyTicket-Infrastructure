# Production Environment

## Purpose

Đây là root module Terraform cho environment **production** — môi trường
phục vụ người dùng thật, cần mức kiểm soát cao nhất trong toàn bộ repository.
Environment này compose các module trong [`../../modules`](../../modules)
và cấu hình theo giá trị dành riêng cho production, không chứa logic tạo
resource trực tiếp (theo nguyên tắc ở [`terraform/README.md`](../../README.md)).

## Current state

`main.tf`, `variables.tf`, `outputs.tf`, `versions.tf` của environment này
hiện đang **trống hoàn toàn** — chưa có resource/module nào được compose.

## Usage (khi bắt đầu triển khai)

1. Khai báo `terraform` block và `required_providers` trong `versions.tf`
   (tham khảo [`../dev/versions.tf`](../dev/versions.tf)).
2. Khai báo `provider "aws"` trong `main.tf`.
3. Compose các module cần thiết theo đúng cấu hình production (ví dụ nhiều
   AZ hơn, instance size lớn hơn, bật thêm module `monitoring`):

```hcl
provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Environment = "production"
    Project     = "easyticket"
  }
}

module "vpc" {
  source = "../../modules/network"

  vpc_name = "easyticket-production-vpc"
  vpc_cidr = var.vpc_cidr
  vpc_azs  = var.vpc_azs

  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  database_subnets = var.database_subnets

  vpc_tags = local.common_tags
}
```

4. Khai báo biến tương ứng trong `variables.tf` và cấu hình giá trị qua
   `terraform.tfvars` hoặc CI/CD secret store — **không commit secret**.
5. State phải dùng **remote backend có locking** (ví dụ S3 + DynamoDB), khai
   báo trong `versions.tf`/`backend.tf`.

## Deployment flow

Production **không được** `terraform apply` trực tiếp từ máy cá nhân. Mọi
thay đổi phải đi qua:

```text
Pull Request → terraform plan (CI) → Code Review → Approval → terraform apply (CI/CD)
```

Đặc biệt chú ý các plan có `destroy`, `replace`, hoặc `-/+` (destroy và
recreate) — cần hiểu rõ nguyên nhân trước khi cho apply. Xem thêm mục
"Production Changes" trong [`terraform/README.md`](../../README.md).

## Notes

- Không copy nguyên `main.tf` của `dev`/`staging` sang — chỉ copy cấu trúc
  rồi chỉnh lại configuration cho đúng quy mô/độ an toàn của production.
- Mọi resource chỉ dùng riêng cho production (ví dụ backup, DR) có thể khai
  báo trực tiếp tại đây nếu không có nhu cầu tái sử dụng ở environment khác.
