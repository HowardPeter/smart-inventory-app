import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
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
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/widgets/t_custom_dialog_widget.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/inventory/controllers/category_detail_controller.dart';
import 'package:frontend/features/inventory/controllers/product_catalog_detail_controller.dart';
import 'package:frontend/features/inventory/providers/inventory_provider.dart';

class ProductFormController extends GetxController with TErrorHandler {
  final InventoryProvider _provider = InventoryProvider();

  // ===========================================================================
  // 1. KHAI BÁO BIẾN (STATE & CONTROLLERS)
  // ===========================================================================

  /// Form keys dùng để validate (kiểm tra rỗng, lỗi) trước khi gửi API
  final GlobalKey<FormState> baseFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> packageFormKey = GlobalKey<FormState>();

  /// Quản lý trạng thái UI chung
  final RxInt currentStep = 1.obs; // Dành cho luồng tạo mới (Step 1 -> 3)
  final RxBool isSaving = false.obs; // Khóa nút bấm khi đang gọi API
  final RxBool isPickingImage =
      false.obs; // Hiệu ứng xoay khi đang mở thư viện ảnh

  /// Xác định Form đang được dùng để làm gì ('create', 'info', 'image', 'edit_package', 'add_package')
  final RxString formMode = 'create'.obs;
  bool isEditMode = false;

  /// Chứa dữ liệu cũ truyền từ màn hình trước sang để edit
  ProductModel? productToEdit;
  ProductPackageModel? packageToEdit;

  // --- TRƯỜNG DỮ LIỆU: ẢNH ---
  final ImagePicker _picker = ImagePicker();
  final Rx<XFile?> selectedImage = Rx<XFile?>(null); // Ảnh mới chọn từ thiết bị
  final RxString existingImageUrl = ''.obs; // Link ảnh cũ từ backend

  // --- TRƯỜNG DỮ LIỆU: THÔNG TIN GỐC (PRODUCT) ---
  final TextEditingController nameController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final Rx<CategoryModel?> selectedCategory = Rx<CategoryModel?>(null);
  List<CategoryModel> allCategories = [];
  bool isCategoryLocked =
      false; // Khóa không cho đổi danh mục nếu truyền từ Category Detail sang

  // --- TRƯỜNG DỮ LIỆU: CẤU HÌNH GÓI HÀNG (PACKAGE) ---
  final TextEditingController packageDisplayNameController =
      TextEditingController();
  final TextEditingController importPriceController = TextEditingController();
  final TextEditingController salePriceController = TextEditingController();
  final TextEditingController thresholdController =
      TextEditingController(text: '0');
  final TextEditingController barcodeController = TextEditingController();

  /// Mock data các đơn vị tính (Sẽ thay bằng API sau này)
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

  // ===========================================================================
  // 2. VÒNG ĐỜI & KHỞI TẠO (LIFECYCLE)
  // ===========================================================================

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
    _parseArguments();
  }

  /// Hàm đọc tham số truyền sang từ trang trước (Arguments) và gán vào các Controller
  void _parseArguments() {
    if (Get.arguments == null) return;

    if (Get.arguments is Map) {
      final args = Get.arguments as Map<String, dynamic>;
      formMode.value = args['mode'] ?? 'create';

      // 1. Nếu có gửi Product -> Chế độ Edit
      if (args['product'] != null) {
        isEditMode = true;
        isCategoryLocked = true;
        productToEdit = args['product'] as ProductModel;
        nameController.text = productToEdit!.name;
        brandController.text = productToEdit!.brand ?? '';
        existingImageUrl.value = productToEdit!.imageUrl ?? '';
      }

      // 2. Nếu có gửi Package -> Đổ data của Package vào UI
      if (args['package'] != null) {
        packageToEdit = args['package'] as ProductPackageModel;
        packageDisplayNameController.text = packageToEdit!.displayName;
        importPriceController.text = packageToEdit!.importPrice.toString();
        salePriceController.text = packageToEdit!.sellingPrice.toString();
        barcodeController.text = packageToEdit!.barcodeValue ?? '';
        selectedUnitId.value = packageToEdit!.unitId;

        _fetchAndSetThreshold(packageToEdit!.productPackageId);
      }

      // 3. Nếu truyền từ Category Detail sang -> Khóa ô chọn Danh mục
      if (args['category'] != null) {
        isCategoryLocked = true;
        selectedCategory.value = args['category'] as CategoryModel;
      }
    } else if (Get.arguments is CategoryModel) {
      isCategoryLocked = true;
      selectedCategory.value = Get.arguments as CategoryModel;
    }
  }

  /// Load danh sách Category để người dùng chọn
  Future<void> _loadCategories() async {
    try {
      allCategories = await _provider.getCategories();
      if (isEditMode && productToEdit != null) {
        selectedCategory.value = allCategories
            .firstWhereOrNull((c) => c.categoryId == productToEdit!.categoryId);
      }
    } catch (e) {
      handleError(
          e); // Bẫy lỗi và báo cho người dùng nếu không load được danh mục
    }
  }

  /// Tải thông số Cảnh báo tồn kho (Threshold) từ backend và gán vào Input
  Future<void> _fetchAndSetThreshold(String packageId) async {
    try {
      final threshold =
          await _provider.getInventoryThresholdByPackage(packageId);
      thresholdController.text = threshold.toString();
    } catch (e) {
      debugPrint("Could not fetch threshold: $e");
      thresholdController.text = '0';
    }
  }

  // ===========================================================================
  // 3. ĐIỀU HƯỚNG WIZARD (STEP NAVIGATION)
  // ===========================================================================

  /// Tiến tới bước tiếp theo (Có kèm Validate logic)
  void nextStep() {
    if (currentStep.value == 1) {
      // Validate rỗng và danh mục
      if (baseFormKey.currentState?.validate() != true) return;
      if (selectedCategory.value == null) {
        TSnackbarsWidget.warning(
            title: TTexts.errorTitle.tr,
            message: TTexts.selectCategoryWarning.tr);
        return;
      }
      currentStep.value = 2;
    } else if (currentStep.value == 2) {
      // Hỏi xác nhận nếu cố tình không chọn ảnh
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

  /// Quay lại bước trước
  void previousStep() {
    if (currentStep.value > 1) currentStep.value--;
  }

  // ===========================================================================
  // 4. XỬ LÝ ẢNH (IMAGE PICKER & CROPPER)
  // ===========================================================================

  /// Mở Camera hoặc Thư viện, sau đó gọi thư viện Crop ảnh theo tỷ lệ 1:1 vuông
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
          aspectRatio: const CropAspectRatio(
              ratioX: 1, ratioY: 1), // Ép tỉ lệ 1:1 cho ảnh sản phẩm
          uiSettings: [
            AndroidUiSettings(
              // Cấu hình thanh công cụ phía trên
              toolbarTitle: TTexts.cropImage.tr,
              toolbarColor: AppColors.background, // Trắng
              toolbarWidgetColor: AppColors.primaryText, // Chữ đen/xám đậm

              // Cấu hình vùng cắt
              backgroundColor: AppColors.background, // Trắng
              activeControlsWidgetColor:
                  AppColors.primary, // Màu cam chủ đạo khi nhấn nút
              statusBarColor: AppColors.background,

              // Cấu hình các nút chức năng (Gọn gàng hơn)
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true, // Khóa tỉ lệ vuông
              hideBottomControls: false, // Hiện nút xoay ảnh nếu cần
              showCropGrid: true, // Hiện lưới để căn chỉnh cho đẹp
            ),
            IOSUiSettings(
              title: TTexts.cropImage.tr,
              aspectRatioLockEnabled: true, // Khóa tỉ lệ vuông trên iOS
              resetButtonHidden: false,
              aspectRatioPickerButtonHidden: true, // Ẩn nút chọn tỉ lệ khác
              doneButtonTitle: TTexts.done.tr, // Text nút hoàn tất
              cancelButtonTitle: TTexts.cancel.tr, // Text nút hủy
            ),
          ],
        );

        if (croppedFile != null) selectedImage.value = XFile(croppedFile.path);
      }
    } catch (e) {
      if (!e.toString().contains('camera_access_denied')) handleError(e);
    } finally {
      isPickingImage.value = false;
    }
  }

  /// Xóa ảnh hiện tại (cả link mạng và link máy)
  void removeSelectedImage() {
    selectedImage.value = null;
    existingImageUrl.value = '';
  }

  // ===========================================================================
  // 5. NGHIỆP VỤ LƯU DỮ LIỆU (SAVE DATA TO API)
  // ===========================================================================

  /// Lưu MỚI TOÀN BỘ (Product + Package + Inventory)
  Future<void> saveProduct() async {
    if (packageFormKey.currentState?.validate() != true) return;
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      final productPayload = {
        'name': nameController.text.trim(),
        'brand': brandController.text.trim(),
        'categoryId': selectedCategory.value!.categoryId,
      };
      final newProduct = await _provider.createProduct(productPayload);

      final packagePayload = {
        'displayName': packageDisplayNameController.text.trim(),
        'unitId': selectedUnitId.value,
        'importPrice': double.tryParse(importPriceController.text) ?? 0,
        'sellingPrice': double.tryParse(salePriceController.text) ?? 0,
        'barcodeValue': barcodeController.text.trim(),
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

  /// Cập nhật MỘT MÌNH thông tin Tên, Nhãn hiệu, Danh mục
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

  /// Cập nhật MỘT MÌNH ảnh Sản phẩm
  Future<void> saveProductImage() async {
    if (selectedImage.value == null && existingImageUrl.value.isEmpty) {
      TSnackbarsWidget.warning(
          title: TTexts.errorTitle.tr, message: TTexts.requirePhoto.tr);
      return;
    }
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      FullScreenLoaderUtils.openLoadingDialog(TTexts.saving.tr);

      // TODO: API Upload ảnh thực tế (Ví dụ upload lên Supabase/S3 rồi lấy URL), thêm, sửa ảnh chuyển thành https
      await Future.delayed(const Duration(seconds: 1));
      final mockNewUrl =
          'https://picsum.photos/400/400?random=${DateTime.now().millisecondsSinceEpoch}';

      FullScreenLoaderUtils.stopLoading();

      _triggerRefreshAndClose(
        TTexts.imageUpdatedSuccess.tr,
        newImageUrl: mockNewUrl,
      );
    } catch (e) {
      FullScreenLoaderUtils.stopLoading();
      handleError(e);
    } finally {
      isSaving.value = false;
    }
  }

  /// Cập nhật HOẶC Tạo mới Gói hàng (Package + Inventory)
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
      };

      final inventoryPayload = {
        'reorderThreshold': int.tryParse(thresholdController.text) ?? 0,
      };

      if (formMode.value == 'edit_package' && packageToEdit != null) {
        // Cập nhật Package
        await _provider.updateProductPackage(
            packageToEdit!.productPackageId, packagePayload);

        // Cập nhật Inventory (Không bọc try-catch tĩnh để quăng lỗi đỏ nếu hỏng)
        await _provider.updateInventoryByPackage(
            packageToEdit!.productPackageId, inventoryPayload);

        // Tạo Model Ảo để UI update ngay lập tức
        final updatedPkg = ProductPackageModel(
          productPackageId: packageToEdit!.productPackageId,
          displayName: packageDisplayNameController.text.trim(),
          importPrice: double.tryParse(importPriceController.text) ?? 0,
          sellingPrice: double.tryParse(salePriceController.text) ?? 0,
          barcodeValue: barcodeController.text.trim(),
          unitId: selectedUnitId.value,
          productId: productToEdit!.productId,
          activeStatus: packageToEdit!.activeStatus,
        );

        FullScreenLoaderUtils.stopLoading();
        _triggerRefreshAndClose(TTexts.packageUpdatedSuccess.tr,
            updatedPackage: updatedPkg);
      } else {
        // Tạo mới Package và Inventory
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

  // ===========================================================================
  // 6. UI HELPERS (BOTTOM SHEETS & DIALOGS)
  // ===========================================================================

  /// Hàm đóng Form, làm mới lại danh sách ở màn hình cũ (Catalog/Detail) và báo thành công
  void _triggerRefreshAndClose(String successMessage,
      {String? newName,
      String? newBrand,
      String? newImageUrl,
      ProductPackageModel? updatedPackage}) {
    // 1. Refresh lại màn hình danh sách Product
    if (Get.isRegistered<CategoryDetailController>()) {
      Get.find<CategoryDetailController>().fetchProducts(isRefresh: true);
    }

    // 2. Refresh lại màn hình Catalog (Chi tiết Product)
    if (Get.isRegistered<ProductCatalogDetailController>()) {
      final detailCtrl = Get.find<ProductCatalogDetailController>();

      if (updatedPackage != null) {
        detailCtrl.updateLocalPackage(updatedPackage); // Ép UI cập nhật mượt mà
      } else {
        detailCtrl.fetchPackages(isRefresh: true);
      }

      detailCtrl.updateLocalInfo(
          name: newName, brand: newBrand, imageUrl: newImageUrl);
    }

    Get.back(); // Thoát khỏi form
    Future.delayed(const Duration(milliseconds: 300), () {
      TSnackbarsWidget.success(
          title: TTexts.successTitle.tr, message: successMessage);
    });
  }

  /// Mở Bottom Sheet tìm kiếm và chọn Category
  void openCategoryPicker() {
    if (isCategoryLocked) return;

    TBottomSheetWidget.show(
      title: TTexts.selectCategory.tr,
      child: Container(
        // Giới hạn chiều cao và thêm khoảng cách dưới để tránh dính sát màn hình
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
                // Tạo đường kẻ mảnh giữa các item cho chuyên nghiệp
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  color: AppColors.divider,
                  indent: 12,
                  endIndent: 12,
                ),
                itemBuilder: (context, index) {
                  final cat = allCategories[index];
                  // Obx để đổi màu icon check nếu danh mục đang được chọn
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
                      // Hiển thị icon check bên phải nếu đang chọn danh mục đó
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

  /// Dialog hỏi xác nhận khi người dùng lỡ tay vuốt thoát khỏi form đang nhập dở
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
