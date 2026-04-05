import 'package:frontend/core/infrastructure/models/product_package_model.dart';
import 'package:get/get.dart';

class AdjustmentItemRx {
  final String id;
  final String packageId;
  final String name;

  final ProductPackageModel? packageInfo;

  RxInt systemQty;
  RxInt actualQty;
  RxBool isChecked;
  RxString selectedReason;
  RxString note;

  AdjustmentItemRx({
    required this.id,
    required this.packageId,
    required this.name,
    required int initialSystemQty,
    this.packageInfo,
  })  : systemQty = initialSystemQty.obs,
        actualQty = initialSystemQty.obs,
        isChecked = false.obs,
        selectedReason = ''.obs,
        note = ''.obs;

  int get spread => actualQty.value - systemQty.value;
  bool get isMismatched => isChecked.value && spread != 0;
}
