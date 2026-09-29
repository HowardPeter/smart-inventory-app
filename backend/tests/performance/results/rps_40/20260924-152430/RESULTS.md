## RPS 40 – Backend Rate Limiter Enabled

### Analyze

Ở `40 RPS`, backend rate limiter bị trigger và trả về `HTTP 429`.

CloudWatch backend ghi nhận:

`Rate limit exceeded`

Các request đến từ cùng một IP nên nhiều request bị giới hạn bởi backend rate limiter.

### Conclusion

`40 RPS` chưa phản ánh capacity thực của hệ thống vì **backend rate limiter đang là bottleneck nhân tạo**.

Cần tắt hoặc điều chỉnh rate limiter trong bài test capacity để đánh giá chính xác khả năng xử lý của các tầng phía sau.
