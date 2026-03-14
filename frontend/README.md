# ✨ Smart Inventory ✨

> **Smart Inventory Management System** – Hệ thống Quản lý Kho Thông Minh

<p align="center">
  <a href="https://flutter.dev">
    <img alt="Flutter" src="https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png" height="50" width="50" style="border-radius:100%;">
  </a>
  &nbsp;&nbsp;
  <a href="https://dart.dev">
    <img alt="Dart" src="https://upload.wikimedia.org/wikipedia/commons/7/7e/Dart-logo.png" height="50" width="50" style="border-radius:100%;">
  </a>
  &nbsp;&nbsp;
  <a href="https://getx.dev">
    <img alt="GetX" src="https://avatars.githubusercontent.com/u/44576995?s=200&v=4" height="50" width="50" style="border-radius:100%;">
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com">
    <img alt="Git" src="https://git-scm.com/images/logos/downloads/Git-Icon-1788C.png" height="50" width="50" style="border-radius:100%;">
  </a>
</p>

---

# 🎯 Tổng quan

**Smart Inventory** là hệ thống giúp doanh nghiệp quản lý kho hàng một cách **hiệu quả, tự động và trực quan**.

Ứng dụng cho phép:

- quản lý sản phẩm
- quản lý tồn kho
- theo dõi nhập / xuất kho
- kiểm soát dữ liệu kho theo thời gian thực
- phân tích và thống kê dữ liệu

Frontend được phát triển bằng **Flutter** với kiến trúc **Feature-First + GetX Pattern** nhằm đảm bảo:

- dễ mở rộng
- dễ bảo trì
- module độc lập
- hiệu năng cao

---

# 🏗️ Kiến trúc hệ thống

Ứng dụng áp dụng **Feature-First Architecture kết hợp GetX Pattern**

```
┌───────────────────────────┐
│        Flutter App        │
│        (Frontend)         │
│                           │
│  ┌─────────────────────┐  │
│  │       Features      │  │
│  │                     │  │
│  │ - Auth              │  │
│  │ - Inventory         │  │
│  │ - Products          │  │
│  │ - Dashboard         │  │
│  └─────────────────────┘  │
│           ▲                │
│           │                │
│  ┌─────────────────────┐  │
│  │       GetX          │  │
│  │                     │  │
│  │ - State Management  │  │
│  │ - Routing           │  │
│  │ - Dependency        │  │
│  │   Injection         │  │
│  └─────────────────────┘  │
└───────────────────────────┘
```

---

# 📁 Cấu trúc thư mục

```
lib/
│
├── core/                               # ⚙️ Thành phần core dùng chung toàn app
│   │
│   ├── constants/                      # Hằng số toàn hệ thống
│   │     ├── api_constants.dart
│   │     ├── image_constants.dart
│   │
│   ├── network/                        # Cấu hình API
│   │     ├── api_client.dart
│   │     └── interceptors.dart
│   │
│   ├── theme/                          # Design system
│   │     ├── app_colors.dart
│   │     ├── app_sizes.dart
│   │     └── app_text_styles.dart
│   │
│   ├── widgets/                        # Widget tái sử dụng toàn app
│   │     ├── t_button.dart
│   │     └── t_text_field.dart
│   │
│   └── utils/                          # Helper functions
│         ├── validators.dart
│         └── formatter.dart
│
│
├── features/                           # ✨ Các module chức năng
│
│   ├── auth/                           # Module Authentication
│   │     ├── bindings/
│   │     ├── controllers/
│   │     ├── views/
│   │     └── widgets/
│
│   ├── inventory/                      # Module quản lý kho
│   │     ├── bindings/
│   │     ├── controllers/
│   │     ├── views/
│   │     └── widgets/
│
│   ├── product/                        # Module quản lý sản phẩm
│   │     ├── bindings/
│   │     ├── controllers/
│   │     ├── views/
│   │     └── widgets/
│
│
├── routes/                             # 🛣️ Quản lý routing
│   ├── app_pages.dart
│   └── app_routes.dart
│
└── main.dart                           # 🚀 Entry point
```

---

# 🛠️ Công nghệ sử dụng

### Frontend

- **Flutter** 3.x
- **Dart**
- **GetX**
- **REST API**
- **Material Design**

### Tools

- **Git**
- **GitHub**
- **VS Code / Android Studio**
- **Figma**

---

# 🚀 Cài đặt và chạy dự án

## Yêu cầu hệ thống

- Flutter SDK 3.x
- Dart SDK
- Android Studio / VS Code
- Git

---

## Clone repository

```bash
git clone https://github.com/your-org/smart-inventory-frontend.git
cd smart-inventory-frontend
```

---

## Cài đặt dependencies

```bash
flutter pub get
```

---

## Run project

```bash
flutter run
```

---

# 📝 Quy tắc phát triển

## Quy tắc đặt tên

### Files & Folders

Flutter sử dụng **snake_case**

```
inventory_controller.dart
product_list_view.dart
inventory_card.dart
```

❌ Không dùng

```
InventoryController.dart
productListView.dart
```

---

### Variables

Dùng **camelCase**

```dart
String productName = "Laptop";
int productQuantity = 20;
```

---

### Classes

Dùng **PascalCase**

```dart
class InventoryController extends GetxController {}

class ProductListView extends StatelessWidget {}
```

---

### Constants

Dùng **UPPER_CASE**

```dart
const String API_BASE_URL = "https://api.example.com";
```

---

# 🧾 Conventional Commits

Format:

```
type(scope): description
```

---

## Commit Types

| Type     | Meaning                |
| -------- | ---------------------- |
| feat     | thêm tính năng         |
| fix      | sửa bug                |
| docs     | cập nhật documentation |
| style    | format code            |
| refactor | refactor code          |
| test     | thêm test              |
| chore    | maintenance            |

---

## Examples

```bash
feat(auth): add login screen

feat(inventory): implement inventory list page

fix(product): resolve product loading bug

docs(readme): update installation guide

refactor(auth): simplify login controller logic
```

---

# 🌿 Branch Naming Convention

```
main
develop
```

---

## Feature Branch

```
feature/inventory-dashboard
feature/product-management
feature/login-ui
```

---

## Bug Fix Branch

```
fix/inventory-loading
fix/login-validation
```

---

## Hotfix Branch

```
hotfix/crash-on-start
```

---

# ⚠️ Quy tắc làm việc

### 1️⃣ Không push trực tiếp vào `main`

Workflow:

```
feature branch
↓
pull request
↓
review
↓
merge develop
```

---

### 2️⃣ Pull trước khi push

```
git pull origin develop
```

---

### 3️⃣ Không commit file build

`.gitignore`

```
build/
.dart_tool/
.idea/
.vscode/
```

---

### 4️⃣ Code phải pass analyze

```
flutter analyze
```

---

### 5️⃣ Format code trước khi commit

```
flutter format .
```

---

# 📄 License

Smart Inventory Project
All rights reserved © 2026

---

# ❤️ Contributors

Developed by **Smart Inventory Team**

---

