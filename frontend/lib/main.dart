import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/bindings/initial_binding.dart';
import 'package:frontend/core/localization/app_translations.dart';
import 'package:frontend/core/services/auth_service.dart';
import 'package:frontend/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:device_preview/device_preview.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
// import 'core/network/api_client.dart'; // Sau này mở ra để inject ApiClient

void main() async {
  // Đảm bảo Flutter core đã được khởi tạo trước khi chạy các setup khác
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------
  // KHỞI TẠO CÁC DỊCH VỤ TOÀN CẦU (GLOBAL SERVICES) Ở ĐÂY
  // Ví dụ: Get.put(ApiClient());

  // 1. Khởi tạo GetStorage
  await GetStorage.init();
  // 2. Khởi tạo AuthService một cách bất đồng bộ
  // Việc dùng putAsync giúp App chờ AuthService check ổ cứng xong mới chạy tiếp
  await Get.putAsync(() => AuthService().init());
  // ---------------------------------------------------------
  // 3. Khởi tạo supabase để kích hoạt các tính năng authen
  await Supabase.initialize(
    url: 'http://10.0.2.2:54321',
    anonKey: 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH',
  );

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
      builder: DevicePreview.appBuilder,

      // 2. Cấu hình Theme (Chỉ dùng Light Theme nguyên bản)
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Ép app luôn chạy ở chế độ Sáng
      // 3. Khai báo bộ dịch
      translations: AppTranslations(),

      // 4. Ngôn ngữ mặc định khi mở app
      locale: const Locale('en', 'US'),

      // 5. Khai báo danh sách binding toàn cục
      initialBinding: InitialBinding(),

      // 6. Cấu hình Định tuyến (Routing)
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,

      // 7. Quản lý bộ nhớ của GetX (Giữ nguyên factory để tránh lỗi trùng lặp controller)
      smartManagement: SmartManagement.keepFactory,
    );
  }
}
