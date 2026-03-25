import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/core/infrastructure/constants/app_constants.dart';
import 'package:frontend/core/infrastructure/localization/app_translations.dart';
import 'package:frontend/core/state/bindings/initial_binding.dart';
import 'package:frontend/core/state/services/auth_service.dart'
    show AuthService;
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/state/services/user_service.dart';
import 'package:frontend/routes/app_pages.dart';
import 'package:get/get.dart';
import 'package:device_preview/device_preview.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/ui/theme/app_theme.dart';
// import 'core/network/api_client.dart'; // Sau này mở ra để inject ApiClient

void main() async {
  // Đảm bảo Flutter core đã được khởi tạo trước khi chạy các setup khác
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("⚠️ .env not found, using default values");
  }
  // ---------------------------------------------------------
  // KHỞI TẠO CÁC DỊCH VỤ TOÀN CẦU (GLOBAL SERVICES) Ở ĐÂY

  // 1. Khởi tạo GetStorage
  await GetStorage.init();
  // 2. Khởi tạo AuthService một cách bất đồng bộ
  // Việc dùng putAsync giúp App chờ AuthService check ổ cứng xong mới chạy tiếp
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => UserService().init());
  await Get.putAsync(() => StoreService().init());
  // ---------------------------------------------------------
  // 3. Khởi tạo supabase để kích hoạt các tính năng authen
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
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
      builder: (context, child) {
        // 1. Cấu hình của DevicePreview
        final devicePreviewChild = DevicePreview.appBuilder(context, child);

        // 2. Bọc toàn bộ App bằng GestureDetector
        return GestureDetector(
          onTap: () {
            // Lệnh này sẽ tự động tìm TextField đang mở và bỏ focus (tắt bàn phím)
            FocusManager.instance.primaryFocus?.unfocus();
          },
          // Phải có behavior này để nó nhận diện click trên khoảng trống
          behavior: HitTestBehavior.opaque,
          child: devicePreviewChild,
        );
      },

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
