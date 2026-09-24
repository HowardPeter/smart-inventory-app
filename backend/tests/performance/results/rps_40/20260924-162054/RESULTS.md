## RPS 40 – Backend Rate Limiter Disabled

### Analyze

Sau khi tắt backend rate limiter, traffic `40 RPS` có thể đi qua backend mà không bị chặn bởi `HTTP 429`.

Lambda không ghi nhận throttling và số lượng request được xử lý tăng tương ứng với tải.

### Conclusion

`40 RPS` là mức tải phù hợp để tiếp tục đánh giá capacity của backend.

Kết quả này cho thấy **rate limiter không còn là bottleneck**, vì vậy các bài test RPS tiếp theo có thể dùng để tìm bottleneck thực sự ở database/Supabase hoặc các dependency phía sau.
