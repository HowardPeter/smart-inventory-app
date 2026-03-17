import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/services/auth_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ Smart Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Nút Đăng xuất
              await authService.logout();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chào mừng bạn đến với Home!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // KHOẢNG TRẮNG CHỨA THÔNG TIN NGƯỜI DÙNG
            Container(
              padding: const EdgeInsets.all(20),
              width:
                  MediaQuery.of(context).size.width *
                  0.8, // Chiều rộng 80% màn hình
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.security, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Trạng thái: ${authService.isLoggedIn.value ? "Đã đăng nhập" : "Chưa đăng nhập"}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),

                    // HIỂN THỊ EMAIL ĐÃ LƯU TỪ Ổ CỨNG
                    const Text(
                      'Thông tin tài khoản:',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Expanded(
                          // SỬ DỤNG OBX ĐỂ LẮNG NGHE SỰ THAY ĐỔI
                          child: Obx(
                            () => Text(
                              // Gọi thẳng biến từ authService, nếu rỗng thì báo chưa có
                              authService.currentUserEmail.value.isEmpty
                                  ? 'Chưa tải được Email'
                                  : authService.currentUserEmail.value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
