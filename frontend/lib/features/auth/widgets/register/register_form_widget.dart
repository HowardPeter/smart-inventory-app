import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/features/auth/widgets/shared/auth_tab_toggle_widget.dart';
import 'package:frontend/features/auth/controllers/register_controller.dart';

class RegisterFormWidget extends GetView<RegisterController> {
  const RegisterFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. THANH TRƯỢT (isLogin: false vì đây là trang Sign Up)
        const AuthTabToggleWidget(isLogin: false),

        const SizedBox(height: 32),

        // 2. KHU VỰC FORM ĐĂNG KÝ (Load tức thì)
        Column(
          children: [
            // Tạm thời để Text chờ ráp UI TextFields (Name, Email, Pass,...)
            const Center(
              child: Text("Đây là Form Đăng Ký", textAlign: TextAlign.center),
            ),
          ],
        ),
      ],
    );
  }
}
