import 'dart:async';
import 'package:frontend/core/widgets/t_snackbars_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/features/auth/providers/auth_provider.dart';

class VerifyEmailController extends GetxController {
  final AuthProvider authProvider;

  VerifyEmailController({required this.authProvider});

  // Biến lưu email nhận từ trang trước
  String email = '';

  // Trạng thái đếm ngược 45s
  var timerCountdown = 45.obs;
  Timer? _timer;

  // Trạng thái loading khi bấm Resend
  var isResending = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 1. Nhận email thông qua Get.arguments thay vì constructor của View
    email = Get.arguments ?? '';

    // 2. Tự động chạy đồng hồ 45s khi vừa vào trang
    startTimer();
  }

  void startTimer() {
    timerCountdown.value = 45;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerCountdown.value > 0) {
        timerCountdown.value--;
      } else {
        timer.cancel(); // Dừng đồng hồ khi về 0
      }
    });
  }

  void resendEmail() async {
    // Nếu đồng hồ chưa đếm xong thì chặn không cho bấm
    if (timerCountdown.value > 0) return;

    isResending.value = true;
    try {
      await authProvider.sendPasswordResetEmail(email);

      TSnackbars.success(
        title: 'Email Sent',
        message: 'A new reset link has been sent to $email.',
      );

      // Gửi thành công thì bắt đầu đếm ngược lại từ đầu
      startTimer();
    } catch (e) {
      TSnackbars.error(
        title: 'Error',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isResending.value = false;
    }
  }

  void openMailApp() {
    TSnackbars.info(
      title: 'Open Mail',
      message: 'This feature will open the Mail app on your device.',
    );
  }

  @override
  void onClose() {
    _timer?.cancel(); // Nhớ hủy timer khi thoát trang để tránh tràn bộ nhớ
    super.onClose();
  }
}
