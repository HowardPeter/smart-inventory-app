import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordController extends GetxController with TErrorHandler {
  final formKey = GlobalKey<FormState>();

  // Thêm Controller cho mật khẩu cũ
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final supabase = Supabase.instance.client;

  Future<void> updatePassword() async {
    if (!formKey.currentState!.validate()) return;
    isLoading.value = true;

    try {
      // 1. Lấy thông tin user hiện tại để lấy Email
      final user = supabase.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('Phiên đăng nhập không hợp lệ.');
      }

      // 2. KIỂM TRA MẬT KHẨU CŨ
      // Bằng cách thử đăng nhập lại với email đang dùng và mật khẩu cũ user vừa nhập
      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: oldPasswordController.text,
      );

      // 3. Nếu đoạn code trên không throw lỗi, nghĩa là mật khẩu cũ ĐÚNG.
      // Bây giờ mới tiến hành cập nhật mật khẩu mới!
      await supabase.auth.updateUser(
        UserAttributes(password: newPasswordController.text),
      );

      // 4. Thành công
      Get.snackbar('Thành công', 'Đổi mật khẩu thành công!');

      // Dọn dẹp form
      oldPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } on AuthException catch (e) {
      // Nếu lỗi ở bước 2 (Mật khẩu cũ sai) hoặc bước 3
      String errorMsg = e.message;
      if (e.message.contains('Invalid login credentials')) {
        errorMsg = 'Mật khẩu hiện tại không chính xác!';
      }

      Get.snackbar('Lỗi', errorMsg);
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
