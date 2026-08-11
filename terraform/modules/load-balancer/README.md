# Load Balancer Module (Template)

> Module này hiện **chưa có nội dung triển khai** (`main.tf`, `variables.tf`,
> `outputs.tf` đều đang trống). README dưới đây chỉ là **mẫu gợi ý** dựa theo
> tên module, hãy sửa lại cho đúng với nhu cầu thực tế trước khi sử dụng.

## Purpose (dự kiến)

Tạo Load Balancer (ALB/NLB) để phân phối traffic tới các target compute
(EC2/ECS) của ứng dụng, hỗ trợ health check và routing.

## Gợi ý resource cần định nghĩa

- `aws_lb`, `aws_lb_listener`, `aws_lb_target_group`.
- Đặt trong public subnet của module [`network`](../network/README.md).
- Gắn security group từ module
  [`security-group`](../security/security-group/README.md) cho phép traffic
  từ internet vào (80/443).
- Target group trỏ tới resource từ module [`compute`](../compute/README.md).

## Gợi ý Inputs

| Name          | Type           | Required | Description                     |
| ------------- | -------------- | -------- | ---------------------------------|
| `name`        | `string`       | yes      | Tên load balancer                |
| `vpc_id`      | `string`       | yes      | VPC chứa load balancer            |
| `subnet_ids`  | `list(string)` | yes      | Subnet (thường là public) đặt LB  |
| `security_group_ids` | `list(string)` | yes | Security group gắn vào LB      |
| `target_port` | `number`       | yes      | Port của target (ứng dụng)        |
| `tags`        | `map(string)`  | no       | Tag áp dụng                       |

## Gợi ý Outputs

| Name        | Description               |
| ----------- | ---------------------------|
| `dns_name`  | DNS name của load balancer  |
| `arn`       | ARN của load balancer       |

## Notes

- Đây chỉ là khung mẫu, có thể sửa toàn bộ cấu trúc (input/output/resource)
  cho phù hợp khi bắt đầu triển khai thật.
- Sau khi implement xong, hãy cập nhật lại README này theo đúng format ở
  [`terraform/README.md`](../../README.md) mục "Module Documentation".
