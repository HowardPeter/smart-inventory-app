import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/state/services/supabase_storage_service.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/models/category_model.dart';
import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/infrastructure/utils/full_screen_loader_utils.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/controllers/category_detail_controller.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_detail_controller.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';

class ProductFormController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();
  final SupabaseStorageService _supabaseStorageService =
      SupabaseStorageService();

  // ==========================================
  // 1. STATE & FORM KEYS
  // ==========================================
  final GlobalKey<FormState> baseFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> packageFormKey = GlobalKey<FormState>();

  final RxInt currentStep = 1.obs;
  final RxBool isSaving = false.obs;
  final RxBool isPickingImage = false.obs;

  final RxString formMode = 'create'.obs;
  bool isEditMode = false;

  ProductModel? productToEdit;
  ProductPackageModel? packageToEdit;

  // ==========================================
  // 2. DATA FIELDS (INPUTS)
  // ==========================================
  // --- Ảnh ---
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString existingImageUrl = ''.obs;

  // --- Thông tin Base ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  List<CategoryModel> allCategories = [];
  bool isCategoryLocked = false;

  // --- Thông tin Package ---
  final TextEditingController packageDisplayNameController =
      TextEditingController();
  final TextEditingController importPriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();

  // Đã bỏ giá trị '0' mặc định, để input trống tự nhiên
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
  final RxString selectedUnitId = ''.obs;

  // ==========================================
  // 3. LIFECYCLE (INIT & DISPOSE)
  // ==========================================
  @override
  void onInit() {
    super.onInit();
    _loadCategories();
    _parseArguments();
  }

  void _parseArguments() {
    if (Get.arguments == null) return;

    if (Get.arguments is Map) {
      final args = Get.arguments as Map<String, dynamic>;
      formMode.value = args['mode'] ?? 'create';

      if (args['product'] != null) {
        isEditMode = true;
        isCategoryLocked = true;
        productToEdit = args['product'] as ProductModel;
        nameController.text = productToEdit!.name;
        brandController.text = productToEdit!.brand ?? '';
        existingImageUrl.value = productToEdit!.imageUrl ?? '';
      }

      if (args['package'] != null) {
        packageToEdit = args['package'] as ProductPackageModel;

        packageDisplayNameController.text = packageToEdit!.displayName;
        importPriceController.text = packageToEdit!.importPrice.toString();
        salePriceController.text = packageToEdit!.sellingPrice.toString();
        barcodeController.text = packageToEdit!.barcodeValue ?? '';
        selectedUnitId.value = packageToEdit!.unitId;

        _fetchAndSetThreshold(packageToEdit!.productPackageId);
      }

      if (args['category'] != null) {
        isCategoryLocked = true;
        selectedCategory.value = args['category'] as CategoryModel;
      }
    } else if (Get.arguments is CategoryModel) {
      isCategoryLocked = true;
      selectedCategory.value = Get.arguments as CategoryModel;
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
      handleError(e);
    }
  }

  Future<void> _fetchAndSetThreshold(String packageId) async {
    try {
      final threshold =
          await _provider.getInventoryThresholdByPackage(packageId);
      // Nếu threshold = 0 thì để trống cho UI đẹp, ngược lại thì hiện số
      thresholdController.text = threshold == 0 ? '' : threshold.toString();
    } catch (e) {
      thresholdController.text = '';
    }
  }

  // ==========================================
  // 4. SMART AUTO-FILL LOGIC
  // ==========================================
  // ==========================================
  // 4. SMART AUTO-FILL LOGIC
  // ==========================================
  List<String> get variantNameSuggestions {
    if (formMode.value == 'edit_package' || packageToEdit != null) {
      return [];
    }

    final unitId = selectedUnitId.value;
    if (unitId.isEmpty) return [];

    final unit = mockUnits.firstWhereOrNull((u) => u['id'] == unitId);
    if (unit == null) return [];

    final unitName = unit['name']!;
    final unitCode = unit['code']!; // Lấy Code (CAN, BOX, BTL...) để phân tích
    final productName = nameController.text.trim();

    if (productName.isEmpty) return [unitName, '1 $unitName'];

    List<String> suggestions = [];

    suggestions.add('$productName $unitName');

    switch (unitCode) {
      case 'CAN':
      case 'BTL':
        suggestions.addAll([
          '330ml $productName $unitName',
          '500ml $productName $unitName',
          '1.5L $productName $unitName',
        ]);
        break;

      case 'BOX':
      case 'CRT':
        suggestions.addAll([
          '6-Pack $productName $unitName',
          '12 $unitName of $productName',
          '24 $productName $unitName',
        ]);
        break;

      case 'PKT':
      case 'BAG':
        suggestions.addAll([
          'Small $productName $unitName',
          'XL $productName $unitName',
          '500g $productName $unitName',
        ]);
        break;

      case 'PCS':
        suggestions.addAll([
          'Standard $productName',
          'Premium $productName',
          'Single $productName $unitName',
        ]);
        break;

      case 'TUBE':
        suggestions.addAll([
          '50g $productName $unitName',
          '150ml $productName $unitName',
        ]);
        break;

      default:
        suggestions.addAll([
          'Standard $productName $unitName',
          'Premium $productName $unitName',
        ]);
    }

    return suggestions;
  }

  // Hàm khi người dùng bấm vào Chip
  void selectVariantSuggestion(String suggestion) {
    packageDisplayNameController.text = suggestion;
  }

  // ==========================================
  // 5. NAVIGATION (WIZARD STEPS)
  // ==========================================
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

  // ==========================================
  // 6. IMAGE HANDLING (PICK & CROP)
  // ==========================================
  Future<void> pickImage(ImageSource source) async {
    if (isPickingImage.value) return;
    try {
      isPickingImage.value = true;
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

      final XFile? image =
          await _picker.pickImage(source: source, imageQuality: 80);

      if (image != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: TTexts.cropImage.tr,
              toolbarColor: AppColors.background,
              toolbarWidgetColor: AppColors.primaryText,
              backgroundColor: AppColors.background,
              activeControlsWidgetColor: AppColors.primary,
              statusBarColor: AppColors.background,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              hideBottomControls: false,
              showCropGrid: true,
            ),
            IOSUiSettings(
              title: TTexts.cropImage.tr,
              aspectRatioLockEnabled: true,
              resetButtonHidden: false,
              aspectRatioPickerButtonHidden: true,
              doneButtonTitle: TTexts.done.tr,
              cancelButtonTitle: TTexts.cancel.tr,
            ),
          ],
        );

        if (croppedFile != null) {
          selectedImage.value = File(croppedFile.path);
        }
      }
    } catch (e) {
      if (!e.toString().contains('camera_access_denied')) handleError(e);
    } finally {
      isPickingImage.value = false;
    }
  }

  void removeSelectedImage() {
    selectedImage.value = null;
    existingImageUrl.value = '';
  }

  // ==========================================
  // 7. API CALLS (SAVE DATA)
  // ==========================================
  Future<void> saveProduct() async {
    if (packageFormKey.currentState?.validate() != true) return;
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      String? imageUrl;

      if (selectedImage.value != null) {
        imageUrl = await _supabaseStorageService.uploadImage(
            imageFile: selectedImage.value!, folderPath: 'products');

        if (imageUrl == null) {
          FullScreenLoaderUtils.stopLoading();
          TSnackbarsWidget.error(
              title: TTexts.errorTitle.tr,
              message: 'Upload ảnh thất bại. Vui lòng thử lại!');
          return;
        }
      }

      final productPayload = {
        'name': nameController.text.trim(),
        'brand': brandController.text.trim(),
        'categoryId': selectedCategory.value!.categoryId,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
      final newProduct = await _provider.createProduct(productPayload);

      final packagePayload = {
        'displayName': packageDisplayNameController.text.trim(),
        'unitId': selectedUnitId.value,
        'importPrice': double.tryParse(importPriceController.text) ?? 0,
        'sellingPrice': double.tryParse(salePriceController.text) ?? 0,
        'barcodeValue': barcodeController.text.trim(),
        'barcodeType': 'ean',
      };
      final newPackage = await _provider.createProductPackage(
          newProduct.productId, packagePayload);

      final packageId = newPackage['productPackageId'] ?? newPackage['id'];
      await _provider.createInventory({
        'productPackageId': packageId,
        'stockQuantity': 0,
        'reorderThreshold': int.tryParse(thresholdController.text) ?? 0,
      });

      FullScreenLoaderUtils.stopLoading();
      _triggerRefreshAndClose(TTexts.productCreatedSuccess.tr);
    } on DioException catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message:
              e.response?.data?['message'] ?? TTexts.errorUnknownMessage.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> saveProductInfo() async {
    if (baseFormKey.currentState?.validate() != true) return;
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      final payload = {
        'name': nameController.text.trim(),
        'brand': brandController.text.trim(),
        'categoryId': selectedCategory.value!.categoryId,
      };

      await _provider.updateProduct(productToEdit!.productId, payload);

      FullScreenLoaderUtils.stopLoading();
      _triggerRefreshAndClose(
        TTexts.productUpdatedSuccess.tr,
        newName: nameController.text.trim(),
        newBrand: brandController.text.trim(),
      );
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> saveProductImage() async {
    if (selectedImage.value == null) {
      TSnackbarsWidget.warning(
          title: TTexts.errorTitle.tr, message: TTexts.requirePhoto.tr);
      return;
    }
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      final newImageUrl = await _supabaseStorageService.uploadImage(
          imageFile: selectedImage.value!, folderPath: 'products');

      if (newImageUrl == null) {
        FullScreenLoaderUtils.stopLoading();
        TSnackbarsWidget.error(
            title: TTexts.errorTitle.tr, message: 'Upload ảnh thất bại!');
        return;
      }

      final payload = {
        'imageUrl': newImageUrl,
      };
      await _provider.updateProduct(productToEdit!.productId, payload);

      FullScreenLoaderUtils.stopLoading();

      _triggerRefreshAndClose(
        TTexts.imageUpdatedSuccess.tr,
        newImageUrl: newImageUrl,
      );
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> savePackageData() async {
    if (packageFormKey.currentState?.validate() != true) return;
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      final packagePayload = {
        'displayName': packageDisplayNameController.text.trim(),
        'unitId': selectedUnitId.value,
        'importPrice': double.tryParse(importPriceController.text) ?? 0,
        'sellingPrice': double.tryParse(salePriceController.text) ?? 0,
        'barcodeValue': barcodeController.text.trim(),
        'barcodeType': 'ean',
      };

      final inventoryPayload = {
        'reorderThreshold': int.tryParse(thresholdController.text) ?? 0,
      };

      if (formMode.value == 'edit_package' && packageToEdit != null) {
        await _provider.updateProductPackage(
            packageToEdit!.productPackageId, packagePayload);

        await _provider.updateInventoryByPackage(
            packageToEdit!.productPackageId, inventoryPayload);

        final updatedPkg = ProductPackageModel(
          productPackageId: packageToEdit!.productPackageId,
          displayName: packageDisplayNameController.text.trim(),
          importPrice: double.tryParse(importPriceController.text) ?? 0,
          sellingPrice: double.tryParse(salePriceController.text) ?? 0,
          barcodeValue: barcodeController.text.trim(),
          barcodeType: 'ean',
          unitId: selectedUnitId.value,
          productId: productToEdit!.productId,
          activeStatus: packageToEdit!.activeStatus,
        );

        FullScreenLoaderUtils.stopLoading();
        _triggerRefreshAndClose(TTexts.packageUpdatedSuccess.tr,
            updatedPackage: updatedPkg);
      } else {
        final newPackage = await _provider.createProductPackage(
            productToEdit!.productId, packagePayload);
        final pkgId = newPackage['productPackageId'] ?? newPackage['id'];

        await _provider.createInventory({
          'productPackageId': pkgId,
          'stockQuantity': 0,
          'reorderThreshold': inventoryPayload['reorderThreshold'],
        });

        final createdPkg = ProductPackageModel.fromJson(newPackage);

        FullScreenLoaderUtils.stopLoading();
        _triggerRefreshAndClose(TTexts.packageCreatedSuccess.tr,
            updatedPackage: createdPkg);
      }
    } on DioException catch (e) {
      FullScreenLoaderUtils.stopLoading();
      TSnackbarsWidget.error(
          title: TTexts.errorTitle.tr,
          message:
              e.response?.data?['message'] ?? TTexts.errorUnknownMessage.tr);
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      isSaving.value = false;
    }
  }

  // ==========================================
  // 8. UI HELPERS (BOTTOM SHEETS & DIALOGS)
  // ==========================================
  void _triggerRefreshAndClose(String successMessage,
      {String? newName,
      String? newBrand,
      String? newImageUrl,
      ProductPackageModel? updatedPackage}) {
    if (Get.isRegistered<CategoryDetailController>()) {
      Get.find<CategoryDetailController>().fetchProducts(isRefresh: true);
    }

    if (Get.isRegistered<ProductCatalogDetailController>()) {
      final detailCtrl = Get.find<ProductCatalogDetailController>();

      if (updatedPackage != null) {
        detailCtrl.updateLocalPackage(updatedPackage);
      } else {
        detailCtrl.fetchPackages(isRefresh: true);
      }

      detailCtrl.updateLocalInfo(
          name: newName, brand: newBrand, imageUrl: newImageUrl);
    }

    Get.back();
    Future.delayed(const Duration(milliseconds: 300), () {
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr, message: successMessage);
    });
  }

  void openCategoryPicker() {
    if (isCategoryLocked) return;

    TBottomSheetWidget.show(
      title: TTexts.selectCategory.tr,
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.4),
        padding: const EdgeInsets.only(bottom: AppSizes.p16),
        child: allCategories.isEmpty
            ? Center(
                child: Text(
                  TTexts.errorNotFoundMessage.tr,
                  style: const TextStyle(color: AppColors.subText),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: allCategories.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.divider,
                  indent: 12,
                  endIndent: 12,
                ),
                itemBuilder: (context, index) {
                  final cat = allCategories[index];
                  return Obx(() {
                    final isSelected =
                        selectedCategory.value?.categoryId == cat.categoryId;

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.p12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      title: Text(
                        cat.name,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primaryText,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 20)
                          : null,
                      onTap: () {
                        selectedCategory.value = cat;
                        Get.back();
                      },
                    );
                  });
                },
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
