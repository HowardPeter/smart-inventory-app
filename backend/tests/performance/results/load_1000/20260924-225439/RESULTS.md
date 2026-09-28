# Load_1000 - Performance Test Results

## Analyze

Điểm đáng chú ý:

```text
RPS_45       → 44.79 RPS → 0.0074% errors
Load_1000    → 44.49 RPS → 97.34% errors
```

Tức là **RPS gần như giống nhau nhưng kết quả hoàn toàn khác nhau**.

Nguyên nhân là Load_1000 tạo ra áp lực concurrency/cold-start lớn hơn rất nhiều. Trong Load_1000 này xuất hiện thêm:

```text
SSM Parameter Store
ThrottlingException: Rate exceeded
```

và:

```text
PostgreSQL
EMAXCONN max client connections reached, limit: 200
```

→ Bản thân Lambda **không bị throttling**, nhưng các dependency phía sau Lambda không chịu được mức concurrency này.

---

## Conclusion

Các test hiện tại đã xác định được **3 bottleneck khác nhau**:

1. **Backend rate limiter**
   → Bottleneck do configuration, không phải infrastructure capacity.

2. **PostgreSQL/Supabase connection capacity**
   → Đã gây lỗi `Too many connections` ở RPS_50 và `max client connections reached` trong Load_1000.

3. **AWS SSM Parameter Store**
   → Bị `ThrottlingException` khi Lambda phải khởi tạo với concurrency lớn.

SIS hiện có stable operating point khoảng 45 RPS đối với workload `GET /api/inventories`, nhưng chưa đạt mục tiêu HA 1,000 concurrent users.
