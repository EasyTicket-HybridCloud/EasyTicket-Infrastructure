# Compute Module (Template)

> Module này hiện **chưa có nội dung triển khai** (`main.tf`, `variables.tf`,
> `outputs.tf` đều đang trống). README dưới đây chỉ là **mẫu gợi ý** dựa theo
> tên module, hãy sửa lại cho đúng với nhu cầu thực tế trước khi sử dụng.

## Purpose (dự kiến)

Tạo hạ tầng compute chạy ứng dụng — ví dụ EC2 instance, Auto Scaling Group,
hoặc ECS service — để phục vụ workload của EasyTicket.

## Gợi ý resource cần định nghĩa

- `aws_instance` / `aws_launch_template` + `aws_autoscaling_group`, hoặc
  ECS/EKS service tùy vào hướng triển khai.
- Gắn vào subnet của module [`network`](../network/README.md).
- Gắn security group từ module
  [`security-group`](../security/security-group/README.md).
- IAM instance profile nếu instance cần gọi AWS API.

## Gợi ý Inputs

| Name             | Type           | Required | Description                       |
| ---------------- | -------------- | -------- | -----------------------------------|
| `name`           | `string`       | yes      | Tên resource compute               |
| `instance_type`  | `string`       | no       | Loại instance (ví dụ `t3.micro`)   |
| `ami_id`         | `string`       | yes      | AMI dùng để khởi tạo instance      |
| `subnet_ids`     | `list(string)` | yes      | Subnet đặt instance                |
| `security_group_ids` | `list(string)` | yes | Security group gắn vào instance    |
| `key_name`       | `string`       | no       | Key pair SSH                       |
| `tags`           | `map(string)`  | no       | Tag áp dụng                        |

## Gợi ý Outputs

| Name          | Description                |
| ------------- | ----------------------------|
| `instance_id` | ID của instance/ASG          |
| `private_ip`  | Private IP (nếu có)           |

## Notes

- Đây chỉ là khung mẫu, có thể sửa toàn bộ cấu trúc (input/output/resource)
  cho phù hợp khi bắt đầu triển khai thật.
- Sau khi implement xong, hãy cập nhật lại README này theo đúng format ở
  [`terraform/README.md`](../../README.md) mục "Module Documentation".
