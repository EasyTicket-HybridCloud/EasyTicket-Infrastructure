# Monitoring Module (Template)

> Module này hiện **chưa có nội dung triển khai** (`main.tf`, `variables.tf`,
> `outputs.tf` đều đang trống). README dưới đây chỉ là **mẫu gợi ý** dựa theo
> tên module, hãy sửa lại cho đúng với nhu cầu thực tế trước khi sử dụng.

## Purpose (dự kiến)

Thiết lập giám sát và cảnh báo cho hạ tầng — ví dụ CloudWatch Dashboard,
Alarm, Log Group — giúp phát hiện sớm sự cố của các service khác (compute,
cache, load-balancer, messaging...).

## Gợi ý resource cần định nghĩa

- `aws_cloudwatch_log_group` cho các service cần log tập trung.
- `aws_cloudwatch_metric_alarm` cho các metric quan trọng (CPU, memory,
  queue depth, error rate...).
- `aws_cloudwatch_dashboard` (tùy chọn) để tổng hợp view.
- SNS topic (có thể tái sử dụng module [`messaging`](../messaging/README.md))
  để gửi cảnh báo.

## Gợi ý Inputs

| Name             | Type           | Required | Description                     |
| ---------------- | -------------- | -------- | ---------------------------------|
| `name`           | `string`       | yes      | Tên prefix cho resource monitoring|
| `alarm_topic_arn`| `string`       | no       | ARN topic nhận cảnh báo            |
| `log_retention_days` | `number`   | no       | Số ngày lưu log                    |
| `tags`           | `map(string)`  | no       | Tag áp dụng                        |

## Gợi ý Outputs

| Name              | Description                |
| ----------------- | ----------------------------|
| `log_group_name`  | Tên log group được tạo       |
| `dashboard_arn`   | ARN dashboard (nếu có)        |

## Notes

- Đây chỉ là khung mẫu, có thể sửa toàn bộ cấu trúc (input/output/resource)
  cho phù hợp khi bắt đầu triển khai thật.
- Sau khi implement xong, hãy cập nhật lại README này theo đúng format ở
  [`terraform/README.md`](../../README.md) mục "Module Documentation".
