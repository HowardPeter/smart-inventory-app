import 'package:get/get.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_item_controller.dart';

class StockAdjustmentItemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StockAdjustmentItemController());
  }
}
