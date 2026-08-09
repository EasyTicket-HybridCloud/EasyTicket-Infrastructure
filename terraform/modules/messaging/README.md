# Messaging Module (Template)

> Module này hiện **chưa có nội dung triển khai** (`main.tf`, `variables.tf`,
> `outputs.tf` đều đang trống). README dưới đây chỉ là **mẫu gợi ý** dựa theo
> tên module, hãy sửa lại cho đúng với nhu cầu thực tế trước khi sử dụng.

## Purpose (dự kiến)

Cung cấp hạ tầng messaging (ví dụ SQS, SNS, hoặc Kafka/MSK) phục vụ giao
tiếp bất đồng bộ giữa các service của EasyTicket (ví dụ: xử lý đặt vé,
gửi thông báo).

## Gợi ý resource cần định nghĩa

- `aws_sqs_queue` / `aws_sns_topic`, hoặc cluster MSK nếu cần Kafka.
- Policy/IAM cho phép service khác publish/consume.
- Dead-letter queue (nếu dùng SQS) để xử lý message lỗi.

## Gợi ý Inputs

| Name          | Type           | Required | Description                     |
| ------------- | -------------- | -------- | ---------------------------------|
| `name`        | `string`       | yes      | Tên queue/topic                  |
| `type`        | `string`       | no       | `sqs`, `sns`, hoặc `kafka`        |
| `visibility_timeout` | `number` | no      | Timeout xử lý message (SQS)       |
| `tags`        | `map(string)`  | no       | Tag áp dụng                       |

## Gợi ý Outputs

| Name  | Description             |
| ----- | -------------------------|
| `arn` | ARN của queue/topic       |
| `url` | URL của queue (nếu SQS)   |

## Notes

- Đây chỉ là khung mẫu, có thể sửa toàn bộ cấu trúc (input/output/resource)
  cho phù hợp khi bắt đầu triển khai thật.
- Sau khi implement xong, hãy cập nhật lại README này theo đúng format ở
  [`terraform/README.md`](../../README.md) mục "Module Documentation".
