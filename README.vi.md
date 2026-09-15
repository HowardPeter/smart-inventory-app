
# Smart Retail Store Assistant — Storix

<p align="right">
  <a href="README.md">🇬🇧 English</a> | 🇻🇳 Tiếng Việt
</p>

**Smart Retail Store Assistant (Storix)** là nền tảng quản lý hàng tồn kho theo hướng mobile-first dành cho các cửa hàng bán lẻ vừa và nhỏ.

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.fourmonkeysstudio.storix">
    <img src="https://img.shields.io/badge/Google_Play-Storix-0F9D58?logo=googleplay&logoColor=green"/>
  </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Node.js-339933?logo=node.js&logoColor=white" alt="Node.js" />
  <img src="https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white" alt="TypeScript" />
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/AWS-232F3E?logo=amazonaws&logoColor=white" alt="AWS" />
  <img src="https://img.shields.io/badge/Terraform-844FBA?logo=terraform&logoColor=white" alt="Terraform" />
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?logo=githubactions&logoColor=white" alt="GitHub Actions" />
</p>

## Tại sao là Storix?

Việc quản lý hàng tồn kho tại các cửa hàng bán lẻ vừa và nhỏ thường liên quan đến việc nhập dữ liệu lặp đi lặp lại, theo dõi tồn kho thủ công và hạn chế khả năng theo dõi các thay đổi trong kho.

Storix tập hợp các quy trình này vào một nền tảng theo hướng mobile-first, cho phép nhân viên cửa hàng quản lý sản phẩm, theo dõi tồn kho, ghi nhận các giao dịch nhập xuất và nhận cảnh báo từ một ứng dụng duy nhất.

Bằng cách kết hợp quy trình lấy barcode làm trọng tâm, thông báo tự động, các thông tin phân tích tồn kho và các tính năng được hỗ trợ bởi AI, Storix hướng đến việc giúp các hoạt động quản lý hàng tồn kho hằng ngày trở nên nhanh chóng, nhất quán và dễ quản lý hơn.

## Ảnh chụp màn hình / Demo

<p align="center">
  <img src="docs/images/dashboard.jpg" width="18%" alt="Home Dashboard" />
  <img src="docs/images/dashboard-2.jpg" width="18%" alt="Home Dashboard 2" />
  <img src="docs/images/inventory-hub.jpg" width="18%" alt="Inventory Hub" />
  <img src="docs/images/notifications.jpg" width="18%" alt="Inventory List" />
  <img src="docs/images/transaction-history.jpg" width="18%" alt="Transaction History" />
  <img src="docs/images/chatbot.jpg" width="18%" alt="Chatbot" />
  <img src="docs/images/inventory.jpg" width="18%" alt="Inventory" />
  <img src="docs/images/product.jpg" width="18%" alt="Product" />
  <img src="docs/images/restock.jpg" width="18%" alt="Restock" />
</p>

## Tính năng chính

### Quản lý hàng tồn kho

Cung cấp các công cụ cần thiết để quản lý và theo dõi hàng tồn kho một cách chính xác trong các hoạt động hằng ngày.

* Tạo các giao dịch nhập và xuất kho
* Điều chỉnh tồn kho khi xảy ra chênh lệch
* Theo dõi số lượng tồn kho theo thời gian thực

### Quản lý sản phẩm

Cho phép quản lý dữ liệu sản phẩm một cách linh hoạt và hiệu quả.

* Tạo, cập nhật và xóa sản phẩm
* Tạo sản phẩm nhanh chóng bằng cách quét barcode
* Phân loại sản phẩm thông qua quản lý danh mục

### Hệ thống Barcode

Tối ưu hóa việc nhập dữ liệu và tra cứu sản phẩm bằng quy trình lấy barcode làm trọng tâm.

* Quét barcode để tìm kiếm hoặc tạo sản phẩm
* Cache phản hồi từ API barcode bên ngoài để giảm độ trễ
* Ánh xạ trực tiếp giá trị barcode với các product package để tái sử dụng nhanh chóng

### Thông báo

Cung cấp cảnh báo theo thời gian thực để giúp người dùng chủ động xử lý các vấn đề liên quan đến hàng tồn kho.

* Cảnh báo hàng sắp hết
* Đề xuất nhập thêm hàng dựa trên các ngưỡng tồn kho
* Phát hiện các chênh lệch tồn kho bất thường

### Hỗ trợ ra quyết định thông minh

Hỗ trợ quá trình ra quyết định bằng các thông tin phân tích dựa trên dữ liệu và các tính năng được hỗ trợ bởi AI.

* Đề xuất số lượng hàng cần nhập tối ưu
* Xác định các sản phẩm bán nhanh và bán chậm
* Cung cấp dashboard phân tích hàng tồn kho

### Chatbot

Giao diện mobile được chuẩn bị cho chatbot, hướng đến việc hỗ trợ các truy vấn về tồn kho và hướng dẫn vận hành bằng AI trong tương lai.

* Trả lời các câu hỏi liên quan đến hàng tồn kho bằng ngôn ngữ tự nhiên
* Gọi các API backend để thực hiện các thao tác được hỗ trợ

## Công nghệ sử dụng

| Lĩnh vực | Công nghệ |
| --- | --- |
| Mobile | Flutter, Dart |
| Backend | Node.js, TypeScript, Express.js |
| ORM | Prisma |
| Database | PostgreSQL, Supabase |
| Cache | Redis |
| Authentication | Supabase Auth |
| Push Notifications | Firebase Cloud Messaging |
| Cloud | AWS |
| Infrastructure | Terraform |
| CI/CD | GitHub Actions |
| Others | Bash |

## Hạ tầng triển khai

<p align="center">
  <img src="docs/images/infrastructure.jpg" width="75%"/>
</p>

## Cấu trúc dự án

```text
.
├── .agents/                         # Prompts cho chatbot agent
│   ├── skills/
│   └── AGENTS.md
├── backend/
│   ├── src/
│   │   ├── app.ts                   # Express app factory và thiết lập middleware
│   │   ├── server.ts                # Điểm khởi chạy HTTP server
│   │   ├── express.d.ts
│   │   ├── common/                  # Các tiện ích backend dùng chung
│   │   ├── config/
│   │   ├── cron/                    # Các cron job theo lịch cho push notification
│   │   ├── db/                      # Các instance kết nối database
│   │   ├── lambda/                  # Handlers cho các Lambda function
│   │   └── modules/                 # Các module chức năng (mỗi module tuân theo route → controller → service → repository)
│   │       ├── alerts/
│   │       │   ├──controllers/      # Xử lý request
│   │       │   ├──modules/           # Định nghĩa feature module và dependency wiring
│   │       │   ├──repositories/      # Tầng truy cập database
│   │       │   ├──routes/            # Đăng ký route
│   │       │   ├──services/          # Business logic
│   │       │   ├──dtos/              # Data transfer objects cho việc validate request/response
│   │       │   ├──types/             # Type và interface của TypeScript
│   │       │   └──validators/        # Schema và quy tắc validation đầu vào
│   │       ├── audit-log/
│   │       ├── auth/
│   │       ├── barcode/
│   │       ├── categories/
│   │       ├── chat-bot/
│   │       └── ...
│   ├── prisma/                      # Định nghĩa data model của Prisma
│   ├── supabase/                    # Cấu hình Supabase cho môi trường phát triển local
│   ├── tests/                       # Unit test và integration test cho các backend module
│   ├── Dockerfile                   # Docker image cho việc triển khai trên EC2/container
│   ├── Dockerfile.lambda            # Docker image được tối ưu cho triển khai trên AWS Lambda
│   ├── package-lock.json
│   ├── package.json
│   └── tsconfig.json

├── frontend/
│   ├── lib/
│   │   ├── main.dart                # Điểm khởi chạy và khởi tạo ứng dụng
│   │   ├── firebase_options.dart
│   │   ├── core/                    # Hạ tầng dùng chung cho các feature
│   │   │   ├── infrastructure/
│   │   │   ├── state/
│   │   │   └── ui/
│   │   ├── features/                # Các feature module độc lập
│   │   │   ├── auth/
│   │   │   │   ├── bindings/        # Dependency injection
│   │   │   │   ├── controllers/     # Xử lý logic của màn hình
│   │   │   │   ├── models/          # Model riêng của feature
│   │   │   │   ├── providers/       # Gọi API từ backend
│   │   │   │   └── views/           # Giao diện chính của feature
│   │   │   ├── home/
│   │   │   ├── inventory/
│   │   │   ├── navigation/
│   │   │   ├── notification/
│   │   │   ├── transaction/
│   │   │   └── ...
│   │   └── routes/
│   ├── assets/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── linux/
│   ├── macos/
│   ├── windows/
│   └── test/

├── terraform/                       # Infrastructure as Code (AWS)
│   ├── environments/                # Các môi trường infrastructure
│   │   ├── production/
│   │   └── staging/
│   └── modules/                     # Các Terraform module có thể tái sử dụng
│       ├── api_gateway/
│       ├── cloudwatch/
│       ├── ec2/
│       ├── ecr/
│       ├── event_bridge/
│       ├── iam/
│       ├── lambda/
│       ├── networking/
│       ├── route53/
│       ├── s3/
│       ├── sqs/
│       └── ssm_parameter/

├── opt-sis/                         # Cấu hình triển khai self-hosted / on-premise
│   ├── nginx/
│   ├── scripts/
│   └── stacks/

└── .github/                         # Cấu hình GitHub Actions CI/CD
    ├── workflows/
    │   ├── ci-backend.yml
    │   ├── ci-frontend.yml
    │   ├── cd-backend-ec2.yml
    │   ├── cd-backend-lambda.yml
    │   ├── backup.yml
    │   └── database-keep-alive.yml
    ├── actions/
    ├── ISSUE_TEMPLATE/
    └── CODEOWNERS
```

## Điểm nổi bật về kỹ thuật

* Kiến trúc backend theo module với các tầng route, controller, service và repository được tách biệt
* Phát triển backend an toàn về kiểu dữ liệu với TypeScript strict
* Truy cập dữ liệu thông qua Prisma và PostgreSQL
* Quy trình quản lý sản phẩm lấy barcode làm trọng tâm, kết hợp caching response từ API
* Kiểm soát quyền truy cập cửa hàng dựa trên role
* Quản lý infrastructure thông qua Terraform
* CI/CD tự động với GitHub Actions
* Triển khai cloud-native sử dụng các dịch vụ AWS
