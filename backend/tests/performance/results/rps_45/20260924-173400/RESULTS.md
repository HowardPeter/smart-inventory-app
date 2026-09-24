# RPS 45 Test Results

## Analyze

- **Target:** 45 RPS
- **Concurrent Users:** 500
- **Duration:** 300s
- **Actual throughput:** ~44.79 RPS
- **Total requests:** 13,545
- **Error rate:** 0.007% (1/13,545)
- **Mean response time:** ~398 ms
- **Median:** 281 ms
- **P95:** ~718 ms
- **P99:** ~1,014 ms
- **Max:** ~30.08 s

### Infrastructure

- Lambda **Throttles:** 0
- Lambda **Errors:** 1
- Lambda peak concurrency: **56**
- API Gateway **4XX/5XX:** không ghi nhận datapoint
- Lambda và API Gateway có latency trung bình tương đối ổn định trong phần lớn thời gian test.

Test đạt gần đúng target **45 RPS** và chỉ ghi nhận **1 request lỗi**, cho thấy hệ thống vẫn xử lý được mức tải này mà chưa xuất hiện failure rate đáng kể.

Tuy nhiên, vẫn xuất hiện 1 request `SocketTimeoutException` có latency khoảng **30s**, vì vậy cần lưu ý tail latency dù error rate gần bằng 0.

## Conclusion

**RPS 45 có thể được chọn làm capacity hiện tại của SIS theo tiêu chí làm tròn mỗi 5 RPS**, vì test đạt ~44.79 RPS với error rate chỉ ~0.007% và không có Lambda throttling.

> **Current tested capacity: ~45 RPS @ 500 concurrent users.**

Đây là **tested capacity**, chưa phải giới hạn tuyệt đối của hệ thống. Bottleneck hiện tại vẫn liên quan đến tầng database/Supabase đã xác định trong các test RPS cao hơn.
