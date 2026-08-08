# Terraform Infrastructure

Repository này quản lý hạ tầng bằng **Terraform**, được thiết kế theo hướng **modular, scalable và self-service**.

Mục tiêu chính:

* Người mới có thể nhanh chóng hiểu kiến trúc.
* Mỗi team có thể thêm infrastructure mà không cần sửa quá nhiều phần hiện có.
* Resource được tổ chức thành các **module có trách nhiệm rõ ràng**.
* Các environment được quản lý độc lập.
* Có quy tắc rõ ràng về naming, variables, outputs, state và deployment.
* Thay đổi infrastructure có thể được review thông qua Pull Request.
* Hạn chế tối đa việc copy/paste Terraform code giữa các environment.

---

# 1. Architecture Overview

Kiến trúc tổng thể được chia thành 3 lớp:

```text
                         ┌──────────────────────┐
                         │      Developer       │
                         │       DevOps         │
                         └──────────┬───────────┘
                                    │
                                    │ Pull Request
                                    ▼
                         ┌──────────────────────┐
                         │        CI/CD         │
                         │ fmt / validate / plan│
                         │       / apply        │
                         └──────────┬───────────┘
                                    │
                                    ▼
              ┌────────────────────────────────────────┐
              │              Environments              │
              │                                        │
              │   dev       staging       production   │
              └───────────────┬────────────────────────┘
                              │
                              │ compose
                              ▼
              ┌────────────────────────────────────────┐
              │                Modules                 │
              │                                        │
              │ network │ compute │ database │ iam     │
              │ storage │ kubernetes │ monitoring     │
              └───────────────┬────────────────────────┘
                              │
                              ▼
              ┌────────────────────────────────────────┐
              │          Cloud Provider / APIs         │
              │                                        │
              │ AWS / Azure / GCP / Kubernetes / ...   │
              └────────────────────────────────────────┘
```

Có thể hiểu đơn giản:

> **Environment quyết định deploy cái gì, Module quyết định resource được tạo như thế nào.**

---

# 2. Repository Structure

Cấu trúc đề xuất:

```text
terraform/
│
├── README.md
│
├── modules/
│   │
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   └── README.md
│   │
│   ├── compute/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   └── README.md
│   │
│   ├── database/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   └── README.md
│   │
│   ├── storage/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   └── README.md
│   │
│   └── ...
│
├── environments/
│   │
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── backend.tf
│   │   └── versions.tf
│   │
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── backend.tf
│   │   └── versions.tf
│   │
│   └── production/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       ├── outputs.tf
│       ├── providers.tf
│       ├── backend.tf
│       └── versions.tf
│
├── global/
│   ├── iam/
│   ├── dns/
│   └── ...
│
└── scripts/
    ├── fmt.sh
    ├── validate.sh
    └── ...
```

---

# 3. Responsibilities

## `modules/`

Đây là nơi chứa **reusable infrastructure components**.

Ví dụ:

```text
modules/
├── network/
├── compute/
├── database/
├── storage/
├── kubernetes/
├── monitoring/
└── iam/
```

Module nên trả lời câu hỏi:

> "Resource này được tạo như thế nào?"

Ví dụ `modules/database` có thể chịu trách nhiệm tạo:

```text
Database
├── Instance
├── Security Group
├── Subnet Group
├── Parameter Group
└── Monitoring configuration
```

Module **không nên biết** environment cụ thể là `dev`, `staging` hay `production`.

---

## `environments/`

Đây là nơi compose các module thành một infrastructure hoàn chỉnh.

Environment trả lời câu hỏi:

> "Environment này cần những infrastructure nào và cấu hình ra sao?"

Ví dụ:

```text
dev
│
├── network
├── compute
├── database
└── storage
```

Trong khi production có thể:

```text
production
│
├── network
├── compute
├── database
├── storage
├── monitoring
└── backup
```

Hai environment có thể sử dụng cùng một module nhưng truyền configuration khác nhau.

---

## `global/`

Chứa những resource **không thuộc riêng một environment**.

Ví dụ:

```text
global/
├── iam/
├── dns/
├── organization/
└── artifact-registry/
```

Không nên đưa resource environment-specific vào đây.

---

# 4. Dependency Flow

Dependency giữa các thành phần nên đi theo một hướng rõ ràng:

```text
Environment
     │
     ├──────────► Network
     │
     ├──────────► Compute
     │                │
     │                └──────► Network
     │
     ├──────────► Database
     │                │
     │                └──────► Network
     │
     └──────────► Storage
```

Không nên để:

```text
module A
   │
   ▼
module B
   │
   ▼
module A
```

Tức là **tránh circular dependency giữa các module**.

---

# 5. Module Design Principles

Mỗi module phải có interface rõ ràng.

Một module tiêu chuẩn nên có:

```text
module-name/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
└── README.md
```

## `main.tf`

Chứa resource chính.

```hcl
resource "..." "this" {
  ...
}
```

## `variables.tf`

Chứa input của module.

```hcl
variable "name" {
  description = "Name of the resource"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}
```

## `outputs.tf`

Chứa những giá trị module cần expose cho bên ngoài.

```hcl
output "id" {
  description = "Resource ID"
  value       = resource.example.this.id
}
```

## `versions.tf`

Khai báo Terraform và provider requirements.

```hcl
terraform {
  required_version = ">= 1.x"

  required_providers {
    ...
  }
}
```

---

# 6. Module Rule

Một module nên tuân thủ các nguyên tắc sau:

### 6.1 Một module có một responsibility chính

Tốt:

```text
modules/
├── database/
├── network/
└── storage/
```

Không tốt:

```text
modules/
└── everything/
```

`everything` tạo VPC + database + Kubernetes + monitoring + IAM trong một module sẽ rất khó maintain.

---

### 6.2 Module phải reusable

Không hard-code:

```hcl
name = "production-database"
```

Nên:

```hcl
name = "${var.project_name}-${var.environment}-database"
```

---

### 6.3 Không hard-code environment

Không viết:

```hcl
count = var.environment == "production" ? 3 : 1
```

nếu logic đó không thực sự thuộc trách nhiệm của module.

Tốt hơn:

```hcl
variable "instance_count" {
  type = number
}
```

Environment quyết định:

```hcl
module "compute" {
  source = "../../modules/compute"

  instance_count = 3
}
```

Như vậy module không cần biết `production` là gì.

---

# 7. Environment Design

Mỗi environment là một Terraform root module độc lập.

Ví dụ:

```text
environments/
├── dev/
├── staging/
└── production/
```

Mỗi environment có state riêng.

```text
dev        → dev state
staging    → staging state
production → production state
```

Điều này giúp tránh việc thay đổi `dev` ảnh hưởng trực tiếp tới state của `production`.

---

# 8. Environment Configuration

Ví dụ:

```hcl
module "network" {
  source = "../../modules/network"

  name = "${var.project_name}-${var.environment}"

  cidr_block = var.vpc_cidr
}
```

Development:

```hcl
project_name = "my-project"
environment  = "dev"

vpc_cidr = "10.10.0.0/16"
```

Production:

```hcl
project_name = "my-project"
environment  = "production"

vpc_cidr = "10.20.0.0/16"
```

Cùng một module.

Khác configuration.

---

# 9. Naming Convention

Resource naming phải nhất quán.

Format đề xuất:

```text
<project>-<environment>-<component>
```

Ví dụ:

```text
payment-dev-api
payment-dev-database

payment-staging-api
payment-staging-database

payment-production-api
payment-production-database
```

Nếu cần region:

```text
<project>-<environment>-<region>-<component>
```

Ví dụ:

```text
module "compute" {
  source = "../../modules/compute"

  name        = "payment-production-ap-southeast-1-api"
  environment = "production"
}
```

Không sử dụng tên tùy ý giữa các module.

---

# 10. Variables Convention

Variable phải có:

* `description`
* `type`
* `default` nếu thực sự phù hợp
* validation nếu có thể

Ví dụ:

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition = contains(
      ["dev", "staging", "production"],
      var.environment
    )

    error_message = "Environment must be dev, staging or production."
  }
}
```

Không nên tạo variable nếu giá trị đó không có khả năng thay đổi.

Không nên biến mọi thứ thành variable chỉ để "cho flexible".

---

# 11. Outputs Convention

Chỉ expose những thông tin cần thiết.

Ví dụ:

```hcl
output "database_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.this.endpoint
}
```

Không expose toàn bộ resource object nếu không cần thiết.

Output nên đại diện cho **contract của module**.

---

# 12. Adding a New Module

Khi cần thêm infrastructure mới, ví dụ Redis:

## Step 1 — Tạo module

```text
modules/
└── redis/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    └── README.md
```

## Step 2 — Define input

```hcl
variable "name" {
  description = "Redis cluster name"
  type        = string
}

variable "node_count" {
  description = "Number of Redis nodes"
  type        = number
}
```

## Step 3 — Define resource

Trong `main.tf` tạo các resource cần thiết.

## Step 4 — Define output

Ví dụ:

```hcl
output "endpoint" {
  description = "Redis endpoint"
  value       = ...
}
```

## Step 5 — Document module

`modules/redis/README.md` cần giải thích:

```text
Purpose
Inputs
Outputs
Example
Dependencies
Important notes
```

## Step 6 — Consume module

Trong environment:

```hcl
module "redis" {
  source = "../../modules/redis"

  name       = "${var.project_name}-${var.environment}-redis"
  node_count = var.redis_node_count
}
```

---

# 13. Adding a New Resource to an Existing Module

Nếu resource thuộc responsibility của module hiện tại, hãy thêm vào module đó.

Ví dụ:

```text
modules/database/
```

đã quản lý database security group.

Nếu cần thêm parameter group cho database:

```text
modules/database/
├── main.tf
├── variables.tf
└── outputs.tf
```

Có thể thêm trực tiếp vào module.

**Không tạo module mới chỉ vì thêm một resource nhỏ.**

Ngược lại, nếu resource bắt đầu có lifecycle hoặc responsibility riêng, cân nhắc tách thành module.

---

# 14. Adding a New Environment

Ví dụ cần thêm:

```text
qa
```

Tạo:

```text
environments/
└── qa/
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars
    ├── outputs.tf
    ├── providers.tf
    ├── backend.tf
    └── versions.tf
```

Sau đó compose các module cần thiết:

```hcl
module "network" {
  source = "../../modules/network"
  ...
}

module "compute" {
  source = "../../modules/compute"
  ...
}

module "database" {
  source = "../../modules/database"
  ...
}
```

Không copy code từ `production` sang `qa`.

Chỉ copy **structure**, sau đó thay đổi configuration.

---

# 15. Terraform State

State phải được lưu ở **remote backend**.

Không commit:

```text
*.tfstate
*.tfstate.*
```

vào Git.

Mỗi environment phải có state riêng:

```text
state/
├── dev
├── staging
└── production
```

State phải có cơ chế locking nếu backend hỗ trợ.

> State là dữ liệu quan trọng của infrastructure. Không tự ý xóa, sửa hoặc migrate state nếu chưa hiểu rõ impact.

---

# 16. Secrets

Không commit secret vào repository.

Không làm:

```hcl
password = "my-secret-password"
```

Không commit:

```text
terraform.tfvars
```

nếu file này chứa secret.

Thay vào đó sử dụng:

```text
Secret Manager
Environment Variables
CI/CD Secret Store
Vault
Cloud Secret Manager
```

Terraform chỉ nên nhận secret thông qua cơ chế quản lý secret phù hợp.

---

# 17. Deployment Flow

Terraform deployment nên đi qua CI/CD.

Flow đề xuất:

```text
Developer
    │
    ▼
Create Branch
    │
    ▼
Modify Terraform
    │
    ▼
terraform fmt
    │
    ▼
terraform validate
    │
    ▼
Pull Request
    │
    ▼
CI
    │
    ├── fmt
    ├── validate
    ├── lint
    ├── security scan
    └── terraform plan
    │
    ▼
Code Review
    │
    ▼
Merge
    │
    ▼
terraform apply
    │
    ▼
Infrastructure Updated
```

Production không nên cho developer chạy:

```bash
terraform apply
```

trực tiếp trên máy cá nhân.

---

# 18. Local Development

Trước khi tạo Pull Request:

```bash
terraform fmt -recursive
```

Sau đó validate environment:

```bash
cd environments/dev

terraform init
terraform validate
terraform plan
```

Nếu project có lint/security scanning:

```bash
tflint
checkov
```

hoặc tool tương đương được team thống nhất.

---

# 19. Pull Request Rules

Mọi infrastructure change nên đi qua Pull Request.

PR nên mô tả:

```text
## What changed?

- Added Redis module
- Added Redis to dev
- Added Redis configuration

## Why?

Application X requires Redis.

## Impact

- Creates Redis cluster in dev
- No production impact

## Terraform Plan

<plan summary>
```

Reviewer cần kiểm tra:

* Resource có đúng responsibility không?
* Có hard-code không?
* Naming có đúng convention không?
* Có ảnh hưởng environment khác không?
* Có destroy/recreate resource hiện tại không?
* Có secret nào bị expose không?
* State có bị thay đổi bất thường không?
* Có cần backup/migration không?

---

# 20. Production Changes

Production cần được xem là environment có mức kiểm soát cao nhất.

Một production change nên có:

```text
Pull Request
    ↓
Terraform Plan
    ↓
Review
    ↓
Approval
    ↓
Apply
```

Đặc biệt chú ý các Terraform plan có:

```text
-/+
destroy and recreate
destroy
replace
```

Nếu plan có resource bị destroy/recreate, cần hiểu rõ nguyên nhân trước khi apply.

---

# 21. What Should I Do?

## Tôi muốn tạo một database mới

Nếu database là loại đã có module:

```text
modules/database/
```

→ Reuse module.

Không tạo lại resource trực tiếp trong environment.

---

## Tôi muốn hỗ trợ một loại database mới

Ví dụ hiện tại có:

```text
modules/postgres/
```

nhưng cần MySQL.

Nếu lifecycle và configuration khác biệt đáng kể:

```text
modules/
├── postgres/
└── mysql/
```

Có thể tạo module riêng.

---

## Tôi muốn thêm Redis

Nếu chưa có Redis:

```text
modules/
└── redis/
```

Sau đó add vào environment cần sử dụng.

---

## Tôi muốn thêm một environment

Tạo:

```text
environments/<environment-name>/
```

và compose các module cần thiết.

Không duplicate module implementation.

---

## Tôi cần một resource chỉ dùng cho production

Có thể khai báo resource/module invocation tại:

```text
environments/production/
```

nếu resource thực sự chỉ thuộc production.

Không cần tạo module nếu resource quá đơn giản và không có nhu cầu reuse.

---

# 22. When Should I Create a Module?

Không phải resource nào cũng cần module.

### Không cần module

Nếu resource:

* rất nhỏ
* chỉ sử dụng một lần
* thuộc rõ ràng về một environment
* không có logic phức tạp

Có thể đặt trực tiếp trong environment.

### Nên tạo module

Nếu resource:

* được sử dụng ở nhiều environment
* được sử dụng bởi nhiều team
* có nhiều resource đi cùng nhau
* có configuration phức tạp
* có lifecycle riêng
* cần chuẩn hóa cách triển khai

Rule đơn giản:

> **Nếu bạn thấy mình copy/paste cùng một Terraform code lần thứ hai, hãy cân nhắc tạo module.**

---

# 23. Module Documentation

Mỗi module nên có README riêng.

Ví dụ:

```text
modules/database/README.md
```

Nội dung tối thiểu:

````markdown
# Database Module

## Purpose

Creates a managed database.

## Features

- Database instance
- Security group
- Subnet configuration
- Monitoring

## Usage

```hcl
module "database" {
  source = "../../modules/database"

  name = "example"
}
````

## Inputs

| Name           | Type   | Required | Description     |
| -------------- | ------ | -------- | --------------- |
| name           | string | yes      | Database name   |
| engine         | string | yes      | Database engine |
| instance_class | string | no       | Instance size   |

## Outputs

| Name     | Description       |
| -------- | ----------------- |
| endpoint | Database endpoint |
| port     | Database port     |

## Notes

Important implementation details.

````

---

# 24. Versioning

Provider và Terraform version phải được quản lý rõ ràng.

Không nên để mỗi developer sử dụng một version tùy ý.

Ví dụ:

```hcl
terraform {
  required_version = ">= 1.x, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> x.y"
    }
  }
}
````

Khi upgrade Terraform/provider:

1. Tạo PR riêng.
2. Review changelog.
3. Run plan trên non-production.
4. Verify infrastructure.
5. Sau đó mới rollout production.

Không gộp provider upgrade lớn với một feature infrastructure lớn nếu không cần thiết.

---

# 25. Code Style

Terraform code phải được format bằng:

```bash
terraform fmt
```

Quy tắc:

* Sử dụng `snake_case` cho Terraform identifiers.
* Variable name phải mô tả rõ ý nghĩa.
* Output phải có `description`.
* Resource name nên sử dụng `this` khi module chỉ quản lý một resource chính.
* Không tạo abstraction không cần thiết.
* Không copy/paste infrastructure giữa environments.
* Không hard-code environment-specific values trong reusable modules.

Ví dụ:

```hcl
resource "aws_xxx" "this" {
  ...
}
```

thay vì:

```hcl
resource "aws_xxx" "production_database_01" {
  ...
}
```

---

# 26. Ownership

Mỗi module nên có owner rõ ràng.

Có thể bổ sung metadata:

```text
modules/
├── network/       # Platform team
├── kubernetes/    # Platform team
├── database/      # DevOps team
├── monitoring/    # SRE team
└── ...
```

Nếu repository lớn, có thể sử dụng:

```text
CODEOWNERS
```

để tự động request review từ team phụ trách.

---

# 27. Golden Rules

Đây là những rule quan trọng nhất của repository:

### Rule 1

**Không copy/paste Terraform implementation giữa environments.**

### Rule 2

**Reusable infrastructure phải nằm trong `modules/`.**

### Rule 3

**Environment chỉ compose module và cung cấp configuration.**

### Rule 4

**Không hard-code secret trong Git.**

### Rule 5

**Không commit Terraform state.**

### Rule 6

**Production change phải có review và plan.**

### Rule 7

**Module phải có input/output contract rõ ràng.**

### Rule 8

**Một module chỉ nên có một responsibility chính.**

### Rule 9

**Không tạo abstraction chỉ để abstraction.**

### Rule 10

**Nếu thay đổi có khả năng destroy resource, phải hiểu rõ plan trước khi apply.**

---

# 28. The Self-Service Principle

Kiến trúc này được thiết kế để một engineer mới có thể thực hiện flow:

```text
"I need X"
     │
     ▼
Search modules/
     │
     ├── Module exists
     │       │
     │       ▼
     │   Reuse module
     │
     └── Module doesn't exist
             │
             ▼
        Create module
             │
             ▼
        Add documentation
             │
             ▼
        Use in environment
             │
             ▼
        terraform plan
             │
             ▼
        Pull Request
             │
             ▼
          Review
             │
             ▼
           Apply
```

Mục tiêu là engineer **không cần hỏi người khác cách làm những task thông thường**.

Chỉ cần:

1. Đọc README.
2. Tìm module phù hợp.
3. Follow convention.
4. Add module/resource.
5. Run validation.
6. Tạo Pull Request.

---

# 29. Decision Tree

Khi cần thêm infrastructure, sử dụng decision tree sau:

```text
                    Need new infrastructure
                              │
                              ▼
                   Does a module exist?
                       /            \
                     Yes             No
                      │               │
                      ▼               ▼
               Reuse module     Is it reusable?
                                  /       \
                                Yes        No
                                 │          │
                                 ▼          ▼
                          Create module   Add directly
                                 │        to environment
                                 ▼
                            Document it
                                 │
                                 ▼
                         Add to environment
                                 │
                                 ▼
                          terraform plan
                                 │
                                 ▼
                            Pull Request
```

---

# 30. Recommended Future Improvements

Khi repository phát triển, có thể bổ sung:

```text
terraform/
├── modules/
├── environments/
├── global/
├── scripts/
├── .github/
│   └── workflows/
├── .tflint.hcl
├── .terraform-docs.yml
├── CODEOWNERS
└── README.md
```

CI/CD có thể tự động:

```text
terraform fmt
terraform validate
tflint
terraform-docs
security scan
terraform plan
```

Sau đó production có thể yêu cầu approval trước `terraform apply`.

---

# 31. Final Architecture

Kiến trúc cuối cùng nên được hiểu đơn giản như sau:

```text
                         Terraform Repository
                                  │
              ┌───────────────────┼───────────────────┐
              │                   │                   │
              ▼                   ▼                   ▼
           Modules           Environments           Global
              │                   │                   │
              │                   │                   │
       Reusable logic      Environment config    Shared resources
              │                   │                   │
              │                   ▼                   │
              │              Compose modules         │
              │                   │                   │
              └───────────────────┼───────────────────┘
                                  │
                                  ▼
                              Terraform
                                  │
                                  ▼
                         Cloud Infrastructure
```

**Core principle:**

> **Modules define how infrastructure is built.
> Environments define where and with what configuration it is deployed.
> CI/CD defines how changes are validated and deployed.**

Nếu mọi thành viên tuân thủ nguyên tắc này, repository có thể mở rộng từ vài resource lên hàng trăm resource mà vẫn giữ được cấu trúc dễ hiểu, dễ review và dễ onboard người mới.
