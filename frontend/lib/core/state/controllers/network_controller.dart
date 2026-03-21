import 'dart:async';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';

class NetworkController extends GetxController {
  static NetworkController get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // Trạng thái mạng toàn cục
  final RxBool isConnected = true.obs;
  bool _isDialogOpen = false; // Cờ chống mở nhiều dialog cùng lúc

  @override
  void onInit() {
    super.onInit();
    // Lắng nghe sự thay đổi mạng (Bật/Tắt Wifi) xuyên suốt app
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }

  /// Hàm kiểm tra Internet thật sự (Ping Google)
  Future<bool> checkInternetDirectly() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false; // Có sóng nhưng mất mạng
    }
    return false;
  }

  /// Xử lý khi trạng thái mạng phần cứng thay đổi
  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    if (result.contains(ConnectivityResult.none)) {
      isConnected.value = false;
      showNoInternetDialog();
    } else {
      // Có sóng phần cứng -> Ping thử Google xem có internet thật không
      final hasInternet = await checkInternetDirectly();
      if (hasInternet) {
        isConnected.value = true;
        _closeNoInternetDialog();
      } else {
        isConnected.value = false;
        showNoInternetDialog();
      }
    }
  }

  /// Hiển thị Dialog chặn toàn bộ App
  void showNoInternetDialog() {
    if (_isDialogOpen) return;
    _isDialogOpen = true;

    Get.dialog(
      PopScope(
        canPop:
            false, // Chống người dùng bấm nút Back (Trở về) trên Android để thoát Dialog
        child: TCustomDialog(
          icon: const Text('📡', style: TextStyle(fontSize: 40)),
          title: TTexts.netErrorTitle.tr,
          description: TTexts.netErrorDescription.tr,

          // Nút Chính: Nút Reload
          primaryButtonText: TTexts.netErrorReloadBtn.tr,
          onPrimaryPressed: () async {
            // Hiện loading xoay xoay
            FullScreenLoaderUtils.openLoadingDialog(TTexts.netChecking.tr);

            final hasInternet = await checkInternetDirectly();

            FullScreenLoaderUtils.stopLoading();

            if (hasInternet) {
              isConnected.value = true;
              _closeNoInternetDialog();
            } else {
              TSnackbars.error(
                title: TTexts.errorTitle.tr,
                message: TTexts.netErrorRetryFailedMessage.tr,
              );
            }
          },

          // Nút Phụ: Mở cài đặt WiFi
          secondaryButtonText: TTexts.netErrorCheckWifiBtn.tr,
          onSecondaryPressed: () {
            AppSettings.openAppSettings(type: AppSettingsType.wifi);
          },
        ),
      ),
      barrierDismissible: false, // Bấm ra ngoài không tắt được
    );
  }

  /// Đóng Dialog khi có mạng
  void _closeNoInternetDialog() {
    if (_isDialogOpen) {
      _isDialogOpen = false;
      if (Get.isDialogOpen == true) {
        Get.back(); // Đóng Custom Dialog
      }
    }
  }
}
