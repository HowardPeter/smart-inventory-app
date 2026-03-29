import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/features/inventory/controllers/category_detail_controller.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:permission_handler/permission_handler.dart';

class ProductFormController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  final GlobalKey<FormState> baseFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> packageFormKey = GlobalKey<FormState>();

  final RxInt currentStep = 1.obs;
  // BIẾN CHỐNG SPAM CLICK
  final RxBool isSaving = false.obs;
  final RxBool isPickingImage = false.obs;

  // --- ẢNH SẢN PHẨM ---
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  // --- THÔNG TIN GỐC (STEP 1) ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  List<CategoryModel> allCategories = [];
  bool isCategoryLocked = false;

  // --- THÔNG TIN PACKAGE (STEP 3) ---
  final TextEditingController packageDisplayNameController =
      TextEditingController();
  final TextEditingController importPriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController thresholdController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();

  final List<Map<String, String>> mockUnits = [
    {
      'id': '88888888-8888-4888-a888-888888888801',
      'code': 'BOX',
      'name': 'Box'
    },
    {
      'id': '88888888-8888-4888-a888-888888888802',
      'code': 'PCS',
      'name': 'Piece'
    },
    {
      'id': '88888888-8888-4888-a888-888888888803',
      'code': 'CAN',
      'name': 'Can'
    },
    {
      'id': '88888888-8888-4888-a888-888888888804',
      'code': 'CRT',
      'name': 'Carton'
    },
    {
      'id': '88888888-8888-4888-a888-888888888805',
      'code': 'PKT',
      'name': 'Packet'
    },
    {
      'id': '88888888-8888-4888-a888-888888888806',
      'code': 'BTL',
      'name': 'Bottle'
    },
    {
      'id': '88888888-8888-4888-a888-888888888807',
      'code': 'BAG',
      'name': 'Bag'
    },
    {
      'id': '88888888-8888-4888-a888-888888888808',
      'code': 'TUBE',
      'name': 'Tube'
    },
  ];
  final RxString selectedUnitId = '88888888-8888-4888-a888-888888888802'.obs;

  bool isEditMode = false;
  ProductModel? productToEdit;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();

    if (Get.arguments != null) {
      if (Get.arguments is ProductModel) {
        isEditMode = true;
        isCategoryLocked = true;
        productToEdit = Get.arguments as ProductModel;
        nameController.text = productToEdit!.name;
        brandController.text = productToEdit!.brand ?? '';
      } else if (Get.arguments is CategoryModel) {
        isCategoryLocked = true;
        selectedCategory.value = Get.arguments as CategoryModel;
      }
    }
  }

  Future<void> _loadCategories() async {
    try {
      allCategories = await _provider.getCategories();
      if (isEditMode && productToEdit != null) {
        selectedCategory.value = allCategories
            .firstWhereOrNull((c) => c.categoryId == productToEdit!.categoryId);
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> pickImage(ImageSource source) async {
    // Nếu đang mở camera rồi thì chặn luôn, không cho bấm lần 2
    if (isPickingImage.value) return;

    try {
      isPickingImage.value = true;

      // 1. Xin quyền (logic cũ của bạn)
      if (source == ImageSource.camera) {
        var status = await Permission.camera.request();
        if (status.isDenied || status.isPermanentlyDenied) {
          TSnackbarsWidget.error(
              title: TTexts.errorTitle.tr,
              message: TTexts.cameraPermissionDenied.tr);
          if (status.isPermanentlyDenied) openAppSettings();
          return;
        }
      }

      // 2. Chụp/Chọn ảnh
      final XFile? image =
          await _picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        // 3. MỞ GIAO DIỆN CẮT ẢNH (CROP) TỈ LỆ 1:1 VUÔNG
        // 3. MỞ GIAO DIỆN CẮT ẢNH (CROP) LỘT XÁC HOÀN TOÀN
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Ép vuông
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: TTexts.cropImage.tr, // TIÊU ĐỀ
              toolbarColor: AppColors.background, // ĐỒNG BỘ MÀU NỀN APPBAR
              toolbarWidgetColor:
                  AppColors.primaryText, // MÀU CHỮ ĐEN/TRẮNG TÙY THEME
              backgroundColor: AppColors.background, // MÀU NỀN BÊN NGOÀI ẢNH
              activeControlsWidgetColor: AppColors.primary,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,

              // CÁC CỜ NÀY LÀ LINH HỒN CỦA SỰ TỐI GIẢN
              hideBottomControls: true, // GIẤU THANH CÔNG CỤ XẤU XÍ Ở ĐÁY
              showCropGrid: false, // Tắt lưới rườm rà
            ),
            IOSUiSettings(
              title: TTexts.cropImage.tr,
              aspectRatioLockEnabled: true,
              resetButtonHidden: true, // Giấu các nút rườm rà của iOS
              aspectRatioPickerButtonHidden: true,
            ),
          ],
        );

        if (croppedFile != null) {
          selectedImage.value = XFile(croppedFile.path); // Gán ảnh đã cắt
        }
      }
    } catch (e) {
      if (!e.toString().contains('camera_access_denied')) {
        handleError(e);
      }
    } finally {
      // Mở khóa UI
      isPickingImage.value = false;
    }
  }

  void nextStep() {
    if (currentStep.value == 1) {
      if (baseFormKey.currentState?.validate() != true) return;
      if (selectedCategory.value == null) {
        TSnackbarsWidget.warning(
            title: TTexts.errorTitle.tr,
            message: TTexts.selectCategoryWarning.tr);
        return;
      }
      currentStep.value = 2;
    } else if (currentStep.value == 2) {
      // LOGIC KIỂM TRA ẢNH: NẾU KHÔNG CÓ ẢNH THÌ HỎI
      if (selectedImage.value == null) {
        Get.dialog(
          TCustomDialogWidget(
            title: TTexts.confirmNoImageTitle.tr,
            description: TTexts.confirmNoImageMessage.tr,
            icon: const Text('❓', style: TextStyle(fontSize: 40)),
            primaryButtonText: TTexts.yesContinue.tr,
            secondaryButtonText: TTexts.addPhoto.tr,
            onSecondaryPressed: () => Get.back(),
            onPrimaryPressed: () {
              Get.back();
              currentStep.value = 3;
            },
          ),
          barrierDismissible: false,
        );
        return;
      }

      currentStep.value = 3;
    }
  }

  void previousStep() {
    if (currentStep.value > 1) currentStep.value--;
  }

  Future<void> saveProduct() async {
    if (!isEditMode && currentStep.value == 3) {
      if (packageFormKey.currentState?.validate() != true) return;
    } else if (isEditMode) {
      if (baseFormKey.currentState?.validate() != true) return;
    }

    if (isSaving.value) return;

    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      if (isEditMode) {
        // LOGIC EDIT
        final payload = {
          'name': nameController.text.trim(),
          'brand': brandController.text.trim(),
          'categoryId': selectedCategory.value!.categoryId,
        };
        await _provider.updateProduct(productToEdit!.productId, payload);
      } else {
        // ==========================================
        // LOGIC ADD: GỌI 3 API LIÊN TIẾP NHAU
        // ==========================================

        // 1. Tạo Product
        final productPayload = {
          'name': nameController.text.trim(),
          'brand': brandController.text.trim(),
          'categoryId': selectedCategory.value!.categoryId,
        };
        final newProduct = await _provider.createProduct(productPayload);

        // 2. Tạo Package (Lưu kết quả trả về để lấy ID)
        final packagePayload = {
          'displayName': packageDisplayNameController.text.trim(),
          'unitId': selectedUnitId.value,
          'importPrice': double.tryParse(importPriceController.text) ?? 0,
          'sellingPrice': double.tryParse(salePriceController.text) ?? 0,
          'barcodeValue': barcodeController.text.trim(),
          'stockQuantity': 0,
          'reorderThreshold': int.tryParse(thresholdController.text) ?? 0,
        };
        final newPackage = await _provider.createProductPackage(
            newProduct.productId, packagePayload);

        // 3. Lấy ID từ Package vừa tạo để tạo Inventor
        final packageId = newPackage['productPackageId'];

        final inventoryPayload = {
          'productPackageId': packageId,
        };
        await _provider.createInventory(inventoryPayload);

        //TODO: (Phần Upload Ảnh lên Supabase sẽ được tích hợp sau khi API chuẩn bị xong)
      }

      FullScreenLoaderUtils.stopLoading();

      if (Get.isRegistered<CategoryDetailController>()) {
        Get.find<CategoryDetailController>().fetchProducts(isRefresh: true);
      }

      Get.back(); // Đóng form
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr,
          message: TTexts.productCreatedSuccess.tr);
    } on DioException catch (e) {
      FullScreenLoaderUtils.stopLoading();
      debugPrint("❌ API ERROR CỦA BACKEND: ${e.response?.data}");
      TSnackbarsWidget.error(
        title: TTexts.errorTitle.tr,
        message: e.response?.data['message'] ?? TTexts.errorUnknownMessage.tr,
      );
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      isSaving.value = false;
    }
  }

  void openCategoryPicker() {
    if (isCategoryLocked) return;
    final RxString searchQuery = ''.obs;

    TBottomSheetWidget.show(
      title: TTexts.selectCategory.tr,
      child: SizedBox(
        height: Get.height * 0.5,
        child: Column(
          children: [
            TextField(
              onChanged: (val) => searchQuery.value = val,
              decoration: InputDecoration(
                hintText: TTexts.searchHint.tr,
                prefixIcon: const Icon(Icons.search, color: AppColors.softGrey),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final query = searchQuery.value.toLowerCase();
                final filtered = allCategories
                    .where((c) => c.name.toLowerCase().contains(query))
                    .toList();

                if (filtered.isEmpty) {
                  return Center(child: Text(TTexts.errorNotFoundMessage.tr));
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final cat = filtered[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(cat.name,
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600)),
                      onTap: () {
                        selectedCategory.value = cat;
                        Get.back();
                      },
                    );
                  },
                );
              }),
            )
          ],
        ),
      ),
    );
  }

  void confirmExit() {
    Get.dialog(
      TCustomDialogWidget(
        title: TTexts.discardChangesTitle.tr,
        description: TTexts.discardChangesMessage.tr,
        icon: const Text('⚠️', style: TextStyle(fontSize: 40)),
        primaryButtonText: TTexts.discard.tr,
        secondaryButtonText: TTexts.keepEditing.tr,
        onSecondaryPressed: () => Get.back(),
        onPrimaryPressed: () {
          Get.back();
          Get.back();
        },
      ),
      barrierDismissible: false,
    );
  }
}
