Bạn đang làm việc trong backend của dự án Smart Inventory System (SIS).

Nhiệm vụ của bạn là VIẾT LẠI module `/transactions` cho feature:
- tạo giao dịch nhập kho thủ công
- theo đúng data shape đã được CHỐT trong file `transaction.type.ts`

==================================================
1. YÊU CẦU BẮT BUỘC PHẢI ĐỌC TRƯỚC
==================================================

Trước khi sửa code, bạn BẮT BUỘC phải đọc đầy đủ các file sau:

1. `/backend/prisma/schema.prisma`
2. `/backend/CODE_CONVENTION.md`
3. `/backend/eslint.config.ts`
4. `/backend/tsconfig.json`
5. Toàn bộ module `/backend/src/modules/transactions`
6. Các module liên quan nếu đang được gọi từ transactions:
   - `/products`
   - `/product-packages`
   - `/inventories`
   - shared utils / errors / response helpers / middleware

==================================================
2. NGUYÊN TẮC QUAN TRỌNG NHẤT
==================================================

File `transaction.type.ts` đã được tôi tạo và chỉnh lại thủ công để phản ánh
đúng data shape mà module transactions cần dùng.

Vì vậy:

- Bạn PHẢI dùng `transaction.type.ts` làm source of truth ở cấp module
  cho các type/domain shape của transactions.
- Bạn KHÔNG được xóa file `transaction.type.ts`
- Bạn KHÔNG được tự viết lại logic theo shape khác với `transaction.type.ts`
- Bạn KHÔNG được tự thay thế `transaction.type.ts` bằng một hệ type khác
- Nếu thấy điểm nào giữa `transaction.type.ts` và code hiện tại bị lệch,
  hãy sửa code để khớp với `transaction.type.ts`
- Chỉ được chỉnh `transaction.type.ts` nếu có lỗi cú pháp/type rõ ràng,
  còn không thì phải coi file này là chuẩn để triển khai module

Nói ngắn gọn:
- `schema.prisma` là source of truth của database
- `transaction.type.ts` là source of truth của module `/transactions`
- code của controller/service/repository/dto/validator phải align với
  `transaction.type.ts`

==================================================
3. CẤU TRÚC THƯ MỤC PHẢI GIỮ
==================================================

Module transactions có cấu trúc như sau:

.
├── index.ts
├── repositories
│   ├── transaction-detail.repository.ts
│   └── transaction.repository.ts
├── transaction.controller.ts
├── transaction.dto.ts
├── transaction.module.ts
├── transaction.route.ts
├── transaction.service.ts
├── transaction.type.ts
└── transaction.validator.ts

Bạn phải giữ đúng cấu trúc này.

- Không được xóa `transaction.type.ts`
- Không được gộp lại thành structure khác
- Không được tự chuyển repository sang file khác nếu không thực sự cần thiết

==================================================
4. MỤC TIÊU IMPLEMENT
==================================================

Viết lại module `/transactions` cho use case:

UC-ST-01 - Create an inventory import transaction manually

Module phải hỗ trợ flow backend cho tạo giao dịch nhập kho thủ công.

Kết quả mong muốn:
- tạo Transaction
- tạo nhiều TransactionDetail
- cập nhật tồn kho Inventory
- trả response đúng shape DTO
- trả thêm `priceUpdateSuggestions` để frontend hỏi user có muốn cập nhật
  `ProductPackage.importPrice` hay không
- KHÔNG update `ProductPackage.importPrice` ngay trong request tạo transaction

==================================================
5. KIẾN TRÚC / PHÂN TẦNG PHẢI ĐÚNG
==================================================

Controller:
- nhận request
- lấy `storeId`, `userId` từ context/helper hiện có
- lấy dữ liệu đã validate
- gọi service
- trả response theo helper chung của dự án

Service:
- là nơi xử lý business logic chính
- validate business rules
- kiểm tra consistency giữa Product / ProductPackage / Inventory
- tính `totalPrice`
- điều phối quá trình tạo transaction
- tạo `priceUpdateSuggestions`
- dùng transaction DB nếu cần để đảm bảo atomicity

Repositories:
- `transaction.repository.ts`
  - xử lý persistence cho Transaction
- `transaction-detail.repository.ts`
  - xử lý persistence cho TransactionDetail

Các logic liên quan bảng khác phải nằm ở module khác:
- `/products`
- `/product-packages`
- `/inventories`

Không được dồn hết mọi thứ vào transaction repository.

==================================================
6. BUSINESS RULE PHẢI GIỮ
==================================================

Khi tạo import transaction, phải giữ các rule sau:

1. `items` không được rỗng

2. Mỗi item phải hợp lệ:
- có `productId`
- có `productPackageId`
- `quantity > 0`
- `unitPrice >= 0`

3. Không cho phép duplicate `productPackageId` trong cùng 1 transaction
   trừ khi codebase hiện tại có convention khác rất rõ ràng.
   Nếu không có convention rõ, hãy reject.

4. Product phải:
- tồn tại
- thuộc đúng store hiện tại
- đang active

5. ProductPackage phải:
- tồn tại
- thuộc Product đã chọn
- đang active

6. RULE QUAN TRỌNG:
Nếu Product chưa có ProductPackage nào,
backend phải throw business error rõ ràng để frontend hiển thị overlay
tạo nhanh package và inventory cho user.

Error này phải:
- machine-readable
- có error code ổn định, ví dụ: `PRODUCT_HAS_NO_PACKAGE`
- có context như `productId`, `productName` nếu lấy được

7. Sau khi tạo Transaction + TransactionDetail thành công,
Inventory phải được tăng tương ứng theo từng ProductPackage:
- nếu inventory đã có -> cộng quantity
- nếu chưa có -> tạo mới inventory

8. Toàn bộ flow phải atomic:
- nếu 1 bước fail thì rollback toàn bộ

==================================================
7. QUYẾT ĐỊNH VỀ importPrice
==================================================

KHÔNG được tự động update `ProductPackage.importPrice`
ngay khi tạo import transaction.

Flow đúng là:
1. tạo import transaction thành công
2. trả về `priceUpdateSuggestions`
3. frontend hỏi user
4. route khác mới update `ProductPackage.importPrice` nếu user đồng ý

Vì vậy trong task này:
- phải tạo được `priceUpdateSuggestions`
- không được update importPrice trực tiếp trong createImportTransaction

==================================================
8. YÊU CẦU CỤ THỂ THEO FILE
==================================================

Hãy đọc `transaction.type.ts` trước, sau đó viết lại các file còn lại để khớp.

### `transaction.type.ts`
- KHÔNG được xóa
- KHÔNG được thay đổi shape một cách tùy tiện
- dùng file này làm chuẩn type/domain của module

### `transaction.dto.ts`
- định nghĩa request/response DTO
- DTO phải align với `transaction.type.ts`
- không tự bẻ shape khác `transaction.type.ts`

### `transaction.validator.ts`
- validate request body/query/params theo DTO đã chốt
- dùng đúng style validate hiện có của dự án
- không mutate linh tinh ngoài pattern hiện tại của codebase

### `transaction.controller.ts`
- controller mỏng
- chỉ lấy context, gọi service, trả response

### `transaction.service.ts`
- chứa business logic chính
- kiểm tra products, packages, inventory
- tính totalPrice
- gọi repositories
- xử lý atomic transaction
- build response đúng shape
- build `priceUpdateSuggestions`

### `repositories/transaction.repository.ts`
- xử lý tạo Transaction
- chỉ làm phần persistence của Transaction

### `repositories/transaction-detail.repository.ts`
- xử lý tạo TransactionDetail
- có thể có batch create nếu phù hợp schema hiện tại

### `transaction.module.ts`
- wire dependencies đúng với style hiện tại của project

### `transaction.route.ts`
- route cho create import transaction
- dùng đúng middleware auth / storeContext / permission / validator

### `index.ts`
- export đúng theo convention hiện tại

==================================================
9. YÊU CẦU VỀ TYPE VÀ MAPPING
==================================================

Đây là điểm cực kỳ quan trọng:

- Không được để DTO, service return type, repository return type lệch nhau
- Không được để shape của response “tự chế” không khớp với `transaction.type.ts`
- Không được hardcode shape kiểu cũ đã sai
- Nếu cần mapping từ Prisma result -> response DTO,
  hãy mapping rõ ràng và nhất quán

Đặc biệt:
- xử lý `Prisma.Decimal` cẩn thận
- ở boundary API response, trả `number` nếu module hiện tại đang theo kiểu đó
- không để raw Decimal lọt ra response nếu codebase không làm vậy

==================================================
10. QUY TẮC KHÔNG ĐƯỢC VI PHẠM
==================================================

- Không được xóa `transaction.type.ts`
- Không được bỏ qua `transaction.type.ts`
- Không được tự suy đoán lại shape
- Không được invent field không có trong schema
- Không được gọi method không tồn tại ở service/module khác
- Không được sửa module không liên quan nếu không thật sự cần
- Không được chỉ sửa type mà quên sửa runtime code
- Không được over-engineer
- Không được đổi structure thư mục module

==================================================
11. CÁCH LÀM VIỆC BẮT BUỘC
==================================================

Hãy làm theo đúng thứ tự sau:

STEP 1:
Đọc:
- `schema.prisma`
- `transaction.type.ts`
- toàn bộ module `/transactions`
- các module liên quan đang được transactions gọi tới

STEP 2:
Tóm tắt ngắn:
- shape chính trong `transaction.type.ts`
- chỗ nào code hiện tại đang lệch với `transaction.type.ts`
- file nào cần sửa

STEP 3:
Lập kế hoạch sửa theo từng file:
- controller
- dto
- validator
- service
- repositories
- module
- route
- index

STEP 4:
Code lại toàn bộ module `/transactions` để align với `transaction.type.ts`

STEP 5:
Hiển thị code final của tất cả file đã sửa

STEP 6:
Giải thích ngắn:
- bạn đã dùng `transaction.type.ts` như thế nào
- atomic transaction đang được xử lý ra sao
- business rule `PRODUCT_HAS_NO_PACKAGE` đang nằm ở đâu
- `priceUpdateSuggestions` được tạo như thế nào

==================================================
12. CHẤT LƯỢNG CODE
==================================================

Bắt buộc:
- tuân thủ `/backend/CODE_CONVENTION.md`
- tuân thủ `/backend/eslint.config.ts`
- tuân thủ `/backend/tsconfig.json`
- comment bằng tiếng Việt nếu thực sự cần comment
- code rõ ràng, ít tầng thừa
- tên biến/hàm/class đúng convention hiện tại
- response/error theo helper chuẩn của dự án

==================================================
13. NHẮC LẠI ĐIỀU QUAN TRỌNG NHẤT
==================================================

File `transaction.type.ts` đã được chốt lại để phản ánh đúng data shape của module.

Vì vậy:
- phải viết lại module theo `transaction.type.ts`
- không được xóa file này
- không được tự thay shape khác
- mọi layer phải align với file này

Quan trọng:
- `transaction.type.ts` là file bắt buộc phải giữ.
- Nếu bạn đề xuất xóa, thay thế, hoặc bỏ qua `transaction.type.ts` thì đó là sai yêu cầu.
- Mọi DTO, service return type, repository mapping trong module `/transactions`
  phải align với `transaction.type.ts`.
- Trước khi code, bạn phải chỉ ra chỗ nào code hiện tại đang lệch với
  `transaction.type.ts`.