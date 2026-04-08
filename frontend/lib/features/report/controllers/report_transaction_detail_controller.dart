import 'package:frontend/core/infrastructure/models/product_model.dart';
import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_detail_model.dart';
import 'package:frontend/core/infrastructure/models/transaction_model.dart';
import 'package:get/get.dart';

class ReportTransactionDetailController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rx<TransactionModel?> transaction = Rx<TransactionModel?>(null);

  late final String transactionId;

  @override
  void onInit() {
    super.onInit();
    transactionId = Get.arguments?['id'] ?? '';
    fetchTransactionDetail();
  }

  Future<void> fetchTransactionDetail() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    final now = DateTime.now();

    transaction.value = TransactionModel(
      transactionId: transactionId.isEmpty ? 'TRX-105480508' : transactionId,
      type: 'OUTBOUND',
      status: 'COMPLETED',
      totalPrice: 185.50,
      createdAt: now.subtract(const Duration(hours: 2, minutes: 15)),
      note: 'Export for VIP Customer - Order #8892',
      userId: 'user_01',
      items: [
        TransactionDetailModel(
          quantity: 5,
          unitPrice: 24.50,
          productPackageId: 'pkg-1',
          packageInfo: ProductPackageModel(
            productPackageId: 'pkg-1',
            displayName: 'Wireless Bluetooth Earbuds Pro',
            barcodeValue: '8934583945001',
            importPrice: 15.00,
            sellingPrice: 24.50,
            unitId: 'unit-1',
            productId: 'prod-1',
            activeStatus: 'active',
            // 🟢 THÊM MODEL SẢN PHẨM CÓ LINK ẢNH
            product: ProductModel(
              productId: 'prod-1',
              name: 'Wireless Bluetooth Earbuds Pro',
              imageUrl:
                  'https://images.unsplash.com/photo-1590658268037-6bf12165a8df?w=300&q=80',
              createdAt: now,
              updatedAt: now,
              storeId: 'store_1',
              categoryId: 'cat_1',
              activeStatus: 'active',
            ),
          ),
        ),
        TransactionDetailModel(
          quantity: 2,
          unitPrice: 31.50,
          productPackageId: 'pkg-2',
          packageInfo: ProductPackageModel(
            productPackageId: 'pkg-2',
            displayName: 'Anker PowerCore 20000mAh',
            barcodeValue: '8934583111002',
            importPrice: 20.00,
            sellingPrice: 31.50,
            unitId: 'unit-1',
            productId: 'prod-2',
            activeStatus: 'active',
            // 🟢 THÊM MODEL SẢN PHẨM CÓ LINK ẢNH
            product: ProductModel(
              productId: 'prod-2',
              name: 'Anker PowerCore 20000mAh',
              imageUrl:
                  'https://images.unsplash.com/photo-1609091839311-d5365f9ff1c5?w=300&q=80',
              createdAt: now,
              updatedAt: now,
              storeId: 'store_1',
              categoryId: 'cat_1',
              activeStatus: 'active',
            ),
          ),
        ),
      ],
    );

    isLoading.value = false;
  }
}
