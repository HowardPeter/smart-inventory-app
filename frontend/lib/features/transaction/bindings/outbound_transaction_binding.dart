import 'package:get/get.dart';
import 'package:frontend/features/transaction/controllers/outbound_transaction_controller.dart';

class OutboundTransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OutboundTransactionController>(
        () => OutboundTransactionController());
  }
}
