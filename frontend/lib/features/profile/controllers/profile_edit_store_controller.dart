import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/state/services/store_service.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/profile/providers/store_provider.dart';
import 'package:get/get.dart';

class ProfileEditStoreController extends GetxController {
  static ProfileEditStoreController get instance => Get.find();

  // Services & Providers
  final _storeService = Get.find<StoreService>();
  final _storeProvider = StoreProvider();

  // Controllers cho các ô nhập liệu (TextField)
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  // GlobalKey để validate Form
  GlobalKey<FormState> editStoreFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _initializeFields();
  }

  /// Nạp dữ liệu cũ vào các ô nhập liệu khi vừa mở trang
  void _initializeFields() {
    nameController.text = _storeService.currentStoreName.value;
    // addressController.text = _storeService.currentStoreAddress.value;
  }

  /// Logic cập nhật thông tin cửa hàng
  Future<void> updateStoreDetails() async {
    try {
      // 1. Kiểm tra Validate Form (ô trống, định dạng...)
      if (!editStoreFormKey.currentState!.validate()) return;

      // 2. Hiện Loading
      FullScreenLoaderUtils.openLoadingDialog(TTexts.loadingTitle.tr);

      // 3. Chuẩn bị dữ liệu gửi lên Backend
      final String storeId = _storeService.currentStoreId.value;
      final Map<String, dynamic> updateData = {
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      // 4. Gọi Provider để cập nhật vào Database
      await _storeProvider.updateStore(storeId, updateData);

      // 5. Cập nhật lại RAM (StoreService) để trang Profile & EditCard tự nhảy tên mới
      _storeService.currentStoreName.value = nameController.text.trim();

      // 6. Tắt Loading & Thông báo thành công
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.success(
        title: TTexts.successTitle.tr,
        message: TTexts.profileUpdateSuccess.tr,
      );

      // 7. Quay lại trang trước
      Get.back();
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: e.toString(),
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
