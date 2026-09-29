## RPS 50

### Analyze

Test `rps_50` được thực hiện nhằm xác định khả năng xử lý ổn định của backend khi duy trì khoảng **50 requests/second** trong điều kiện nhiều concurrent users.

Kết quả cho thấy hệ thống bắt đầu xuất hiện lỗi **HTTP 500** từ backend. Log CloudWatch ghi nhận lỗi:

> `StorageApiError: Too many connections issued to the database`

Chi tiết lỗi:

```
{
    "level": 50,
    "time": 1790242812418,
    "service": "backend",
    "err": {
        "type": "CustomError",
        "message": "Exception occured while creating signed URL Supabase: CustomError: Error occured while creating signed URL Supabase: StorageApiError: Too many connections issued to the database",
        "stack": "CustomError: Exception occured while creating signed URL Supabase: CustomError: Error occured while creating signed URL Supabase: StorageApiError: Too many connections issued to the database\n    at StorageService.getSignedUrl (file:///var/task/dist/common/utils/get-signed-url.util.js:30:19)\n    at process.processTicksAndRejections (node:internal/process/task_queues:103:5)\n    at async file:///var/task/dist/modules/inventories/service/inventory.service.js:27:31\n    at async Promise.all (index 5)\n    at async InventoryService.getSignedUrlForItemImageUrl (file:///var/task/dist/modules/inventories/service/inventory.service.js:21:16)\n    at async InventoryService.getInventoriesByStoreId (file:///var/task/dist/modules/inventories/service/inventory.service.js:50:36)\n    at async getInventories (file:///var/task/dist/modules/inventories/controller/inventory.controller.js:14:29)",
        "status": 500,
        "isOperational": false,
        "name": "CustomError"
    },
    "path": "/api/inventories",
    "method": "GET",
    "msg": "Request failed"
}

```

Lỗi xảy ra trong quá trình tạo signed URL cho image trên Supabase Storage và được backend chuyển thành `CustomError` với `status: 500`.

Điều này cho thấy request đã vượt qua API Gateway và backend rate limiter, sau đó được xử lý bởi Lambda nhưng thất bại khi truy cập các dịch vụ/database phía Supabase. Vì vậy, **API Gateway không phải bottleneck chính của bài test này**.

Bottleneck hiện tại nằm ở tầng persistence/storage của Supabase, cụ thể là giới hạn số lượng database connections. Backend sử dụng PostgreSQL làm datasource.

Đáng chú ý, lỗi xảy ra trong flow `GET /api/inventories`, trong đó nhiều image URL được xử lý đồng thời thông qua `Promise.all`. Khi số lượng request tăng, số lượng thao tác tới Supabase cũng tăng theo, làm connection demand tăng và cuối cùng vượt quá giới hạn connection của database.

Do đó, **50 RPS không thể được xem là capacity ổn định hiện tại của hệ thống**. Mặc dù Lambda/API Gateway có khả năng tiếp nhận và scale request, downstream database vẫn giới hạn khả năng xử lý tổng thể của hệ thống.

### Conclusion

Kết quả `rps_50` cho thấy **bottleneck hiện tại nằm ở Supabase/PostgreSQL connection capacity**, không phải Lambda concurrency hay API Gateway throttling.

Cụ thể:

- API Gateway đã cho phép traffic đi qua.
- Lambda có thể tiếp nhận request và không bị `Throttles`.
- Backend rate limiter không phải nguyên nhân chính của HTTP 500.
- Backend ghi nhận lỗi `Too many connections issued to the database` từ Supabase.
- Vì vậy, khi traffic đạt khoảng **50 RPS**, database connection capacity trở thành bottleneck và làm phát sinh HTTP 500.

**50 RPS chưa phải mức HA capacity của SIS. Database/connection layer của Supabase đang là giới hạn chính của hệ thống.**
