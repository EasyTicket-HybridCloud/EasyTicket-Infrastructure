# Cache Module (Template)

> Module này hiện **chưa có nội dung triển khai** (`main.tf`, `variables.tf`,
> `outputs.tf` đều đang trống). README dưới đây chỉ là **mẫu gợi ý** dựa theo
> tên module, hãy sửa lại cho đúng với nhu cầu thực tế trước khi sử dụng.

## Purpose (dự kiến)

Cung cấp hạ tầng caching (ví dụ Redis/ElastiCache) cho ứng dụng, dùng để
tăng tốc truy vấn, lưu session, hoặc làm message broker nhẹ.

## Gợi ý resource cần định nghĩa

- `aws_elasticache_cluster` hoặc `aws_elasticache_replication_group`
  (Redis/Memcached).
- `aws_elasticache_subnet_group` liên kết với subnet của
  [`network`](../network/README.md).
- Security group cho phép ứng dụng truy cập vào cache (có thể tái sử dụng
  module [`security-group`](../security/security-group/README.md)).

## Gợi ý Inputs

| Name              | Type           | Required | Description                          |
| ----------------- | -------------- | -------- | -------------------------------------|
| `name`            | `string`       | yes      | Tên cluster cache                    |
| `engine`          | `string`       | no       | `redis` hoặc `memcached`             |
| `node_type`       | `string`       | yes      | Kích thước node                      |
| `subnet_ids`      | `list(string)` | yes      | Subnet đặt cache                     |
| `vpc_id`          | `string`       | yes      | VPC chứa cache                       |
| `tags`            | `map(string)`  | no       | Tag áp dụng                          |

## Gợi ý Outputs

| Name       | Description              |
| ---------- | --------------------------|
| `endpoint` | Endpoint để kết nối cache |
| `port`     | Port của cache             |

## Notes

- Đây chỉ là khung mẫu, có thể sửa toàn bộ cấu trúc (input/output/resource)
  cho phù hợp khi bắt đầu triển khai thật.
- Sau khi implement xong, hãy cập nhật lại README này theo đúng format ở
  [`terraform/README.md`](../../README.md) mục "Module Documentation".
