Bạn đang làm việc trên backend của dự án Smart Inventory System (SIS).

## 1) Bối cảnh dự án
SIS là ứng dụng mobile dành cho cửa hàng tạp hóa nhỏ và vừa, giúp quản lý kho, ghi nhận nhập/xuất và hỗ trợ ra quyết định. Chức năng cần triển khai thuộc nhóm Stock Transactions, use case:
- UC-ST-01: Create an inventory import transaction manually

Use case summary:
- Staff chọn chức năng nhập kho thủ công
- Gõ vài ký tự đầu của tên sản phẩm để tìm
- Hệ thống hiển thị dropdown sản phẩm phù hợp
- User chọn sản phẩm
- User nhập tiếp thông tin cần thiết như số lượng, giá nhập, đơn vị/quy cách tương ứng
- Có thể thêm nhiều dòng sản phẩm
- User confirm để hoàn tất phiếu nhập
- Hệ thống tạo transaction nhập kho và cập nhật tồn kho

Post-conditions:
- Tạo thành công inventory import transaction
- Inventory được cập nhật tương ứng

## 2) Mục tiêu của task này
Hãy đọc codebase backend hiện tại và triển khai chức năng:
- Tạo giao dịch nhập kho thủ công trong module `/transactions`

Tôi muốn bạn:
1. Đọc hiểu structure code hiện tại
2. Tôn trọng coding style/convention hiện tại
3. Triển khai flow backend cho create import transaction
4. Chỉ sửa/thêm những phần cần thiết
5. Giữ boundary module rõ ràng

## 3) Kiến trúc module và boundary bắt buộc
Chức năng này nằm trong module `/transactions`.

Module `/transactions` chịu trách nhiệm chính với:
- bảng `Transaction`
- bảng `TransactionDetail`

Các logic/hàm liên quan tới bảng khác phải nằm đúng module tương ứng:
- `/products`
- `/product-packages`
- `/inventories`

Tức là:
- transaction module không nên ôm toàn bộ logic query/validate/cập nhật của product, product-package, inventory trong repository của chính nó
- transaction service có thể đóng vai trò orchestration use case
- nhưng các hàm đọc/kiểm tra/cập nhật domain khác phải gọi qua service/facade/module tương ứng nếu codebase hiện tại đã có pattern đó

## 4) Coding convention và style cần tuân thủ
Hãy tuân thủ đúng style backend hiện tại của dự án được quy định tại:
  - /backend/CODE_CONVENTION.md
  - /backend/eslint.config.ts

Nếu project đang có các helper như:
- `requireReqUser`
- `requireReqStoreContext`
- `sendResponse`
- `asyncWrapper`
- validator bằng Zod
thì hãy dùng lại đúng pattern đó thay vì tự tạo style mới.

## 5) Giả định domain hiện tại
Dựa trên schema hiện tại của dự án:
- `Transaction` là phiếu header
- `TransactionDetail` là các dòng chi tiết
- `TransactionDetail` gắn với `productPackageId`
- Inventory cũng gắn với `productPackageId`

Vì vậy, nhập kho phải được thực hiện trên package cụ thể, không chỉ trên product chung chung.

Frontend có thể search theo product name, nhưng khi confirm phiếu nhập thì backend cần xử lý trên `productPackageId`.

## 6) Business rules bắt buộc cho createImportTransaction
Hãy triển khai logic service cho use case này với các rule sau:

### Rule A. Validate input cơ bản
- Payload phải có danh sách items
- `items` không được rỗng
- Mỗi item phải hợp lệ
- `quantity` phải > 0
- `unitPrice` phải >= 0 hoặc > 0 tùy logic hiện tại của dự án; nếu chưa có rule sẵn thì dùng `>= 0`
- Nếu có duplicate `productPackageId` trong cùng một transaction thì ưu tiên reject bằng lỗi rõ ràng thay vì âm thầm merge, trừ khi codebase hiện tại đã có pattern merge

### Rule B. Product phải hợp lệ
Với mỗi item:
- Product phải tồn tại
- Product phải thuộc `storeId` hiện tại
- Product phải active nếu schema/domain hiện tại có `activeStatus`

### Rule C. Product phải có ProductPackage
Đây là rule rất quan trọng:
- Nếu user đang tạo transaction nhập cho một Product nhưng Product đó chưa có bất kỳ `ProductPackage` nào, backend phải ném lỗi về frontend
- Lỗi này nhằm để frontend hiển thị overlay/hộp thoại cho phép user tạo nhanh package và inventory

Tôi muốn error này rõ ràng, có thể nhận biết được bằng code, ví dụ kiểu:
- `PRODUCT_HAS_NO_PACKAGE`

Lỗi nên chứa đủ dữ liệu để frontend xử lý UI, ví dụ:
- `productId`
- có thể thêm `productName` nếu thuận tiện

### Rule D. ProductPackage phải hợp lệ
- `productPackageId` phải tồn tại
- Package phải thuộc đúng Product được chọn
- Package phải thuộc đúng store hiện tại thông qua quan hệ với Product
- Package phải active nếu domain có `activeStatus`

### Rule E. Inventory phải được cập nhật atomically
Khi tạo import transaction thành công:
- phải tạo `Transaction`
- phải tạo các `TransactionDetail`
- phải cập nhật `Inventory`

Nếu một bước fail thì rollback toàn bộ.

Đây là case nên dùng `prisma.$transaction`.

## 7) Quyết định nghiệp vụ về importPrice
Tôi KHÔNG muốn auto update `ProductPackage.importPrice` ngay trong lúc tạo import transaction.

Tuy nhiên tôi muốn hỗ trợ flow sau:
- Sau khi tạo import transaction thành công
- Backend có thể trả ra danh sách các package mà `unitPrice` của lô nhập mới khác với `ProductPackage.importPrice` hiện tại
- Frontend sẽ dùng danh sách này để hiển thị hộp thoại hỏi user có muốn cập nhật giá nhập mặc định hay không

Vì vậy:
- Trong `createImportTransaction`, chỉ tạo transaction + details + update inventory
- Không update `ProductPackage.importPrice` ngay
- Nhưng hãy thiết kế output hoặc helper logic để frontend có thể biết package nào đang có chênh lệch giá nhập

Nếu cần, có thể gợi ý thêm route follow-up để check hoặc confirm update giá nhập, nhưng task chính hiện tại vẫn là `createImportTransaction`.

## 8) Mong muốn về phân tầng controller / service / repository
Hãy triển khai đúng trách nhiệm từng layer.

### Controller
Controller chỉ nên:
- lấy `storeId`, `userId` từ request context
- lấy dữ liệu đã validate
- gọi service
- trả response đúng format dự án

Không nhét business logic vào controller.

### Service
Service là nơi orchestration use case.
Service cần xử lý:
- validate nghiệp vụ
- gọi các module khác để kiểm tra product / package / inventory
- tính tổng tiền transaction
- chuẩn bị payload sạch cho repository
- gọi repository để tạo transaction record
- gọi inventory module để cập nhật tồn
- tạo `priceUpdateSuggestions` nếu cần trả về frontend

### Repository
Repository của module transactions chỉ nên tập trung vào:
- `Transaction`
- `TransactionDetail`

Không nên để repository của transactions ôm logic update bảng khác nếu có thể tách đúng module.

Tuy nhiên, nếu để đảm bảo atomic transaction với Prisma, bạn có thể:
- dùng `Prisma.TransactionClient`
- truyền `tx` xuống các service/repository của module khác
miễn là boundary module vẫn rõ và code sạch.

## 9) Điều tôi muốn Codex làm cụ thể
Hãy thực hiện các bước sau, theo thứ tự:

### Bước 1. Đọc codebase hiện tại
- Tìm module `/transactions` nếu đã tồn tại
- Tìm style hiện tại của các module như `/products`, `/inventories`, `/product-packages`
- Tìm các utility/helper đang được dùng chung
- Tìm pattern response, validator, DTO, repository, error handling, prisma usage

### Bước 2. Phân tích trước khi code
Trước khi sửa code, hãy tự xác định:
- các file nào cần tạo mới
- các file nào cần chỉnh sửa
- module nào đang thiếu public method/facade để transaction service có thể gọi
- phần nào cần tái sử dụng thay vì viết mới

### Bước 3. Triển khai createImportTransaction
Ưu tiên các thành phần sau:
- `transaction.dto.ts`
- `transaction.type.ts` nếu cần
- `transaction.validator.ts`
- `transaction.controller.ts`
- `transaction.service.ts`
- `transaction.repository.ts`
- `transaction.route.ts`
- wiring trong `transaction.module.ts` hoặc `index.ts` theo style hiện tại

### Bước 4. Bổ sung các method cần thiết ở module liên quan nếu thiếu
Chỉ thêm những method thực sự cần cho use case này, ví dụ:
- product service/repository: lấy products theo ids, check active/store
- product-package service/repository: check product có package chưa, lấy packages theo ids, snapshot importPrice
- inventory service/repository: tăng tồn kho theo package trong transaction context

Không refactor lan man toàn bộ codebase.

### Bước 5. Giữ API contract rõ ràng
Tôi muốn endpoint cho create import transaction rõ ràng, ví dụ:
- `POST /transactions/import`

Hãy dùng route/path phù hợp với style hiện tại của dự án nếu đã có convention khác.

## 10) Gợi ý payload đầu vào
Nếu codebase chưa có DTO sẵn, bạn có thể theo hướng payload này và điều chỉnh để khớp code hiện tại:

```ts
type CreateImportTransactionDto = {
  note?: string;
  items: Array<{
    productId: string;
    productPackageId: string;
    quantity: number;
    unitPrice: number;
  }>;
};
````

Giữ `productId` trong item để dễ validate:

* product tồn tại
* product có package chưa
* package có thuộc đúng product không

## 11) Gợi ý response đầu ra

Response nên trả đủ để frontend dùng ngay sau khi tạo transaction thành công.
Ví dụ, theo format response chung hiện tại của dự án:

```ts
{
  success: true,
  data: {
    transactionId: '...',
    type: 'import',
    status: 'completed',
    note: '...',
    totalPrice: 123456,
    createdAt: '...',
    items: [
      {
        transactionDetailId: '...',
        productId: '...',
        productPackageId: '...',
        quantity: 10,
        unitPrice: 5000
      }
    ],
    priceUpdateSuggestions: [
      {
        productPackageId: '...',
        currentImportPrice: 4500,
        latestImportUnitPrice: 5000
      }
    ]
  }
}
```

Tên field có thể điều chỉnh để khớp naming/domain hiện tại, nhưng ý nghĩa phải giữ nguyên.

## 12) Yêu cầu về lỗi

Khi business rule fail, hãy dùng error rõ ràng, có message dễ hiểu và nếu project có custom error class / error code constants thì hãy dùng lại.

Đặc biệt với rule product chưa có package:

* trả lỗi có thể phân biệt được ở frontend
* message rõ để frontend bật overlay tạo package/inventory
* không được trả lỗi chung chung kiểu "Bad request"

## 13) Yêu cầu về chất lượng code

* Không viết code giả lập
* Không để TODO nếu không thật sự cần
* Không dùng `any` nếu tránh được
* Tôn trọng `exactOptionalPropertyTypes` và strict typing
* Xử lý `Decimal` đúng nếu schema đang dùng Prisma Decimal
* Không phá vỡ eslint rule hiện tại
* Không đổi style toàn dự án
* Chỉ implement phần cần thiết cho use case này

## 14) Đầu ra tôi muốn từ bạn

Sau khi đọc codebase và triển khai, hãy trả về:

1. Danh sách file đã tạo/sửa
2. Tóm tắt ngắn logic đã implement
3. Code hoàn chỉnh cho các file thay đổi
4. Nếu có quyết định thiết kế quan trọng, giải thích ngắn gọn tại chỗ

## 15) Lưu ý cuối cùng

Ưu tiên đọc code hiện tại trước rồi mới code theo đúng style dự án.
Không tự ý thiết kế lại toàn bộ module nếu không cần.
Nếu có nhiều cách triển khai, hãy chọn cách ít xâm lấn codebase nhất nhưng vẫn đúng nghiệp vụ và đảm bảo transaction atomic.
