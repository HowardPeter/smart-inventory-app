import 'package:get/get.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_controller.dart';

class StockAdjustmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StockAdjustmentController());
  }
}
