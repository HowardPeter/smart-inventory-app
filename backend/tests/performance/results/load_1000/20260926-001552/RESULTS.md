## Analysis

Test với **1,000 concurrent users**, `ramp-up = 300s`, `duration = 360s`, `think time = 10–25s`.

Hệ thống đạt throughput thực tế khoảng **56.1 RPS**, cao hơn mức capacity ~45 RPS xác định trước đó.

Tỷ lệ lỗi giảm mạnh, chỉ còn **12/19,648 requests (~0.061%)**.

Không còn ghi nhận các lỗi:

```
SSM Parameter Store
ThrottlingException: Rate exceeded
```

```
Error occured while creating signed URL Supabase: StorageApiError: Too many connections issued to the database
```

Bottleneck SSM và Supabase Storage đã được giảm đáng kể.

Latency ổn định trong phần lớn thời gian, nhưng có một số spike lên ~10.4s và Lambda có thời điểm đạt concurrency 210.

## Conclusion

Sau khi tối ưu SSM và batch signed URL, SIS đã **cải thiện đáng kể khả năng chịu tải ở 1,000 concurrent users**, đạt khoảng **56 RPS với error rate ~0.061%**.

Kết quả cho thấy 2 bottleneck ở test `load_1000/20260924-225439` và `rps_50/20260924-163856` đã được giảm tải hiệu quả. Bottleneck hiện tại chuyển sang **database connection capacity (`EMAXCONN`, limit 200)**.
