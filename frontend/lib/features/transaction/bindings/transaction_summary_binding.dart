import 'package:get/get.dart';
import 'package:frontend/features/transaction/controllers/transaction_summary_controller.dart';

class TransactionSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => TransactionSummaryController());
  }
}
