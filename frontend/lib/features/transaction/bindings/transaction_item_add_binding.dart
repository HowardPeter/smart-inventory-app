import 'package:frontend/features/transaction/controllers/transaction_item_add_controller.dart';
import 'package:get/get.dart';

class TransactionItemAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TransactionItemAddController>(
        () => TransactionItemAddController());
  }
}
