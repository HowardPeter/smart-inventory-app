## So sánh performance trước và sau khi dùng hàm batch cho image signed url

Before

- Test 1: /20260924-173400
- Test 2: /20260925-195006

After

- Test 1: /20260925-162427
- Test 2: /20260925-184821

### Analyze

Sau khi chuyển từ `getSignedUrl()` cho từng image item sang batch `getBatchSignedUrl()`, hệ thống duy trì throughput ổn định khoảng **45 RPS** trong cả hai lần test.

Kết quả chính:

- **Lambda Duration** giảm khoảng **44–51%**.
- **Lambda Concurrency** giảm đáng kể:
  - Test 1: `56 → 20`
  - Test 2: `63 → 39`
- **Maximum latency** giảm hơn **82%**, từ khoảng 30 giây xuống còn 4.8–5.3 giây.
- Test 1 ghi nhận cải thiện rõ rệt về latency:
  - Mean: `397.8 → 232.8 ms` (-41.5%)
  - P95: `1013.7 → 387.9 ms` (-61.7%)
  - P99: `1591.5 → 668.7 ms` (-58.0%)
- Test 2 có latency biến động hơn, đặc biệt P99 tăng từ `1408.9 → 1629.2 ms`.
- Lambda không bị throttling và After Test không ghi nhận Lambda errors.

Việc batch signed URL làm giảm số lượng request tới Supabase Storage cho mỗi request `/api/inventories`, từ đó giảm downstream fan-out và thời gian xử lý của Lambda.

### Conclusion

Batch Signed URL mang lại **cải thiện performance rõ rệt ở mức tải khoảng 45 RPS**, đặc biệt đối với Lambda Duration, concurrency và các latency spike lớn.

Tuy nhiên, kết quả giữa các lần chạy vẫn có biến động ở P90/P95/P99, nên chưa thể kết luận rằng bottleneck của Supabase đã được giải quyết hoàn toàn.

Có thể giữ optimization này làm baseline cho các capacity test tiếp theo và tiếp tục tăng RPS để xác định giới hạn chịu tải mới của hệ thống.
