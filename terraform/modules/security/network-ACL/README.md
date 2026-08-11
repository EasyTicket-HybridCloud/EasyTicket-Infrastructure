# Network ACL Module (Template)

> Module này hiện **chưa có nội dung triển khai** (`main.tf`, `variables.tf`,
> `outputs.tf` đều đang trống). README dưới đây chỉ là **mẫu gợi ý** dựa theo
> tên module, hãy sửa lại cho đúng với nhu cầu thực tế trước khi sử dụng.

## Purpose (dự kiến)

Quản lý Network ACL (NACL) cho VPC/subnet — lớp kiểm soát traffic ở mức
subnet, hoạt động stateless, bổ sung thêm một lớp bảo vệ ngoài Security
Group.

## Gợi ý resource cần định nghĩa

- `aws_network_acl` gắn với `vpc_id` và danh sách `subnet_ids`.
- `aws_network_acl_rule` (hoặc `ingress`/`egress` block) cho từng rule
  inbound/outbound.
- Có thể tham khảo cách tổ chức của module [`network`](../../network/README.md)
  hoặc [`security-group`](../security-group/README.md) để định nghĩa input
  dạng map cho các rule.

## Gợi ý Inputs

| Name         | Type           | Required | Description                          |
| ------------ | -------------- | -------- | -------------------------------------|
| `vpc_id`     | `string`       | yes      | ID của VPC                           |
| `subnet_ids` | `list(string)` | yes      | Danh sách subnet gắn NACL này         |
| `name`       | `string`       | yes      | Tên NACL                             |
| `ingress`    | `map(object)`  | no       | Map các rule inbound                 |
| `egress`     | `map(object)`  | no       | Map các rule outbound                |
| `tags`       | `map(string)`  | no       | Tag áp dụng cho NACL                 |

## Gợi ý Outputs

| Name  | Description       |
| ----- | ------------------|
| `id`  | ID của NACL        |

## Notes

- Đây chỉ là khung mẫu, có thể sửa toàn bộ cấu trúc (input/output/resource)
  cho phù hợp khi bắt đầu triển khai thật.
- Sau khi implement xong, hãy cập nhật lại README này theo đúng format ở
  [`terraform/README.md`](../../../README.md) mục "Module Documentation".
