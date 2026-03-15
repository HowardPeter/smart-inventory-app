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
├── core/                           # Thành phần cốt lõi, dùng chung toàn app
│   ├── constants/                  # Hằng số hệ thống
│   │   ├── dimension.dart          # Breakpoints (600, 1440)
│   │   ├── image_strings.dart      # Đường dẫn assets/images
│   │   ├── text_strings.dart       # Keys cho Localization (TTexts)
│   │   └── api_endpoints.dart      # URL API
│   ├── layouts/                    # CẤU TRÚC (Engine) điều phối Responsive
│   │   ├── t_responsive_layout.dart # Bộ lọc Mobile/Tablet/Web
│   │   └── t_size_error_layout.dart # Màn hình chặn thiết bị không hỗ trợ
│   ├── localization/               # Đa ngôn ngữ (AppTranslations)
│   ├── network/                    # Cấu hình API Client
│   ├── theme/                      # UI Design System (Colors, Sizes, Theme)
│   ├── utils/                      # Hàm tiện ích (Formatters, Validators)
│   └── widgets/                    # Các thành phần UI nguyên tử (Atomic Components)
│       ├── buttons/                # TPrimaryButton, TBackButton
│       └── t_image_widget.dart     # Widget hiển thị ảnh dùng chung
│
├── features/                       # Các tính năng (Modules) độc lập
│   └── onboarding/                 # Ví dụ: Module Giới thiệu
│       ├── bindings/               # Khởi tạo Dependencies
│       ├── controllers/            # Logic & State (GetxController)
│       ├── layouts/                # GIAO DIỆN (Content) chi tiết từng trang slide
│       │   ├── onboarding_page_one_layout.dart # Trang 1 (Ảnh lẹm phải)
│       │   └── onboarding_standard_layout.dart # Trang chuẩn (Ảnh Aura)
│       ├── views/                  # Điều phối màn hình chính
│       │   ├── onboarding_view.dart # Entry Point (Gọi TResponsiveLayout)
│       │   └── platform/           # Phân tách View theo nền tảng
│       │       ├── onboarding_mobile_view.dart  # View chính trên Mobile
│       │       └── onboarding_desktop_view.dart # View chính trên Desktop
│       └── widgets/                # Widget đặc thù chỉ dùng cho module này
│
├── routes/                         # Quản lý định tuyến (AppPages, AppRoutes)
└── main.dart                       # Điểm khởi chạy ứng dụng
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

### 🧾 Commit Types

| Type         | Purpose                                                | Example                                   |
| :----------- | :----------------------------------------------------- | :---------------------------------------- |
| **feat**     | Add new features                                       | `feat(cart): add shopping cart checkout`  |
| **fix**      | Bug fixes                                              | `fix(api): handle null response error`    |
| **docs**     | Only change documents (README, comment code, etc.)     | `docs(readme): update installation guide` |
| **style**    | Changing the code format (without affecting logic)     | `style(css): format with prettier`        |
| **refactor** | Refactoring the code (no added features, no bug fixes) | `refactor(auth): simplify login logic`    |
| **perf**     | Improved performance                                   | `perf(db): optimize query performance`    |
| **test**     | Add or edit test cases                                 | `test(unit): add tests for user model`    |
| **chore**    | Miscellaneous changes, optimizations, or minor tweaks  | `chore(deps): update lodash to v4.17.21`  |
| **ci**       | Change CI/CD Configuration                             | `ci(github): add linting to workflow`     |
| **build**    | Build-related changes (webpacks, npm scripts, etc.)    | `build(webpack): add production config`   |

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
