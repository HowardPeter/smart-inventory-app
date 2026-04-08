import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';

class ProfileChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final supabase = Supabase.instance.client;

  Future<void> updatePassword() async {
    // 1. Kiểm tra Validate từ Form UI
    if (!formKey.currentState!.validate()) return;

    // 2. Kiểm tra khớp mật khẩu mới
    if (newPasswordController.text != confirmPasswordController.text) {
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.passwordNotMatch.tr,
      );
      return;
    }

    // 3. Kiểm tra mật khẩu mới không được trùng mật khẩu cũ
    if (newPasswordController.text == oldPasswordController.text) {
      TSnackbarsWidget.warning(
        title: TTexts.warningTitle.tr,
        message: TTexts.passwordSameAsOld.tr,
      );
      return;
    }

    isLoading.value = true;

    try {
      final user = supabase.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception(TTexts.authSessionExpired.tr);
      }

      // 4. Xác thực mật khẩu hiện tại (Re-authentication)
      // Việc sử dụng AuthResponse giúp đảm bảo lấy được Session mới nhất
      final AuthResponse authResponse = await supabase.auth.signInWithPassword(
        email: user.email!,
        password: oldPasswordController.text,
      );

      // Kiểm tra session mới từ phản hồi của server
      if (authResponse.session != null) {
        // 5. Tiến hành cập nhật mật khẩu mới vào hệ thống
        await supabase.auth.updateUser(
          UserAttributes(password: newPasswordController.text),
        );

        // 6. Thông báo thành công theo phong cách Modern Clean
        TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.passwordChangedSuccess.tr,
        );

        // Xóa trắng các trường sau khi hoàn tất
        _clearForm();
      } else {
        throw Exception(TTexts.systemError.tr);
      }
    } on AuthException catch (e) {
      // Xử lý các lỗi đặc thù từ Supabase
      String errorMsg = e.message;
      if (e.message.contains('Invalid login credentials')) {
        errorMsg = TTexts.oldPasswordIncorrect.tr;
      }

      TSnackbarsWidget.error(
        title: TTexts.authError.tr,
        message: errorMsg,
      );
    } catch (e) {
      // Xử lý các lỗi ngoại lệ khác (mất mạng, lỗi server...)
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: TTexts.systemError.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Hàm dọn dẹp dữ liệu trên Form
  void _clearForm() {
    oldPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    // Giải phóng bộ nhớ cho các controller
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
