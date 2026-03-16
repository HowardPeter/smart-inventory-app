import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/t_text_form_field_widget.dart';
import 'package:get/get.dart'; // Thêm import này
import 'package:frontend/core/constants/text_strings.dart';
import 'package:frontend/core/theme/app_sizes.dart';
import 'package:frontend/core/widgets/t_primary_button_widget.dart';

// Imports nội bộ
import '../shared/auth_divider_widget.dart';
import '../shared/auth_social_button_widget.dart';
import '../shared/auth_tab_toggle_widget.dart';
import 'login_remember_me_widget.dart';

// Đổi thành GetView<LoginController> để tự động có biến `controller`
import '../../controllers/login_controller.dart';

class LoginFormWidget extends GetView<LoginController> {
  const LoginFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AuthTabToggleWidget(isLogin: true),
        const SizedBox(height: AppSizes.p24),

        // 2. Ô Email (Đã gắn controller)
        TTextFormField(
          controller: controller.emailController, // Lấy từ LoginController
          label: TTexts.emailLabel.tr,
          hintText: TTexts.emailHint.tr,
        ),
        const SizedBox(height: AppSizes.p16),

        // 3. Ô Password (Bọc Obx để cập nhật icon mắt)
        Obx(
          () => TTextFormField(
            controller: controller.passwordController, // Lấy từ LoginController
            label: TTexts.passwordLabel.tr,
            hintText: TTexts.passwordHint.tr,
            obscureText:
                controller.isPasswordHidden.value, // Đọc state từ Controller
            suffixIcon: IconButton(
              icon: Icon(
                controller.isPasswordHidden.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
              ),
              onPressed:
                  controller.togglePasswordVisibility, // Gọi hàm đổi trạng thái
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p8),

        // 4. Remember Me & Forgot Password
        const LoginRememberMeWidget(),
        const SizedBox(height: AppSizes.p24),

        // 5. Nút Login (Đã gọi được controller.login)
        TPrimaryButton(
          text: TTexts.loginBtn.tr,
          onPressed: () => controller.login(),
        ),
        const SizedBox(height: AppSizes.p24),

        const AuthDividerWidget(),
        const SizedBox(height: AppSizes.p24),

        const AuthSocialButtonWidget(),
      ],
    );
  }
}
