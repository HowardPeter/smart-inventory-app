import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:device_preview/device_preview.dart';
import 'core/theme/app_theme.dart';
// import 'core/network/api_client.dart'; // Sau này mở ra để inject ApiClient

void main() async {
  // Đảm bảo Flutter core đã được khởi tạo trước khi chạy các setup khác
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------
  // KHỞI TẠO CÁC DỊCH VỤ TOÀN CẦU (GLOBAL SERVICES) Ở ĐÂY
  // Ví dụ: Get.put(ApiClient());
  // ---------------------------------------------------------

  runApp(
    // Bọc toàn bộ app trong DevicePreview
    DevicePreview(
      // Chỉ bật DevicePreview khi đang code (Debug Mode).
      // Khi xuất file .apk hoặc build lên app store, nó sẽ tự động ẩn đi.
      enabled: !kReleaseMode,
      builder: (context) => const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Inventory',
      debugShowCheckedModeBanner: false,

      // 1. Cấu hình Device Preview kết hợp với GetX
      // Hai dòng này bắt buộc phải có để Device Preview giả lập được màn hình điện thoại
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      // 2. Cấu hình Theme (Chỉ dùng Light Theme nguyên bản)
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Ép app luôn chạy ở chế độ Sáng
      // 3. Cấu hình Định tuyến (Routing)
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // 4. Quản lý bộ nhớ của GetX (Giữ nguyên factory để tránh lỗi trùng lặp controller)
      smartManagement: SmartManagement.keepFactory,
    );
  }
}
