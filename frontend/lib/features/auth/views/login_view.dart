import 'package:flutter/material.dart';
import 'package:frontend/features/auth/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Màn hình Login tạm thời để kiểm tra định tuyến (Routing)
class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_person_rounded, size: 80, color: AppColors.primary),
            SizedBox(height: 20),
            Text(
              'Màn hình Login (Test)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Mọi thứ đang hoạt động bình thường!'),
          ],
        ),
      ),
    );
  }
}
