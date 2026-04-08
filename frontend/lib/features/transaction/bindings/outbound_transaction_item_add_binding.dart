import 'package:frontend/features/transaction/controllers/outbound_transaction_item_add_controller.dart';
import 'package:get/get.dart';

class OutboundTransactionItemAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OutboundTransactionItemAddController>(
        () => OutboundTransactionItemAddController());
  }
}
