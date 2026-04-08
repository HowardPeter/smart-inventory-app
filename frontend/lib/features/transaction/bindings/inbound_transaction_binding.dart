import 'package:get/get.dart';
import '../controllers/inbound_transaction_controller.dart';

class InboundTransactionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InboundTransactionController>(
        () => InboundTransactionController());
  }
}