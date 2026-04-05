import 'package:frontend/features/transaction/controllers/inbound_transaction_item_add_controller.dart';
import 'package:get/get.dart';

class InboundTransactionItemAddBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InboundTransactionItemAddController>(
        () => InboundTransactionItemAddController());
  }
}
