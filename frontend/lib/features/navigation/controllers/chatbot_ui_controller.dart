import 'package:get/get.dart';

class ChatbotUiController extends GetxController {
  static ChatbotUiController get instance => Get.find();

  final RxBool isChatOpen = false.obs;

  void toggleChat() {
    isChatOpen.value = !isChatOpen.value;
  }

  void closeChat() {
    if (isChatOpen.value) {
      isChatOpen.value = false;
    }
  }
}
