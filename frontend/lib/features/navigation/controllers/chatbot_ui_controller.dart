import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/navigation/models/chat_message_model.dart';

class ChatbotUiController extends GetxController with TErrorHandler {
  static ChatbotUiController get instance => Get.find();

  final RxBool isChatOpen = false.obs;

  // Trạng thái Chat
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isTyping = false.obs;

  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // Dùng TTexts cho tin nhắn mặc định
    messages.add(ChatMessage(text: TTexts.chatbotWelcomeMsg.tr, isUser: false));
  }

  void toggleChat() {
    isChatOpen.value = !isChatOpen.value;
  }

  void closeChat() {
    if (isChatOpen.value) {
      isChatOpen.value = false;
    }
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();

    // 🟢 Bẫy lỗi Validation (Rỗng) bằng TSnackbarsWidget thông thường
    if (text.isEmpty) {
      TSnackbarsWidget.warning(
        title: TTexts.warningTitle.tr,
        message: TTexts.chatbotEmptyInputWarning.tr,
      );
      return;
    }

    // 1. Thêm tin nhắn của User vào UI
    messages.add(ChatMessage(text: text, isUser: true));
    textController.clear();
    _scrollToBottom();

    // 2. Hiển thị trạng thái AI đang gõ
    isTyping.value = true;

    try {
      // TODO: GỌI API AI THẬT
      await Future.delayed(const Duration(milliseconds: 1500));

      // GIẢ LẬP LỖI ĐỂ KIỂM TRA ERROR HANDLER MIXIN
      if (text.toLowerCase() == "mạng") {
        throw dio.DioException(
          requestOptions: dio.RequestOptions(path: ''),
          type: dio.DioExceptionType.connectionError,
        );
      }

      if (text.toLowerCase() == "server") {
        throw dio.DioException(
          requestOptions: dio.RequestOptions(path: ''),
          type: dio.DioExceptionType.badResponse,
          response: dio.Response(
              statusCode: 500, requestOptions: dio.RequestOptions(path: '')),
        );
      }

      // 3. Nhận kết quả và thêm tin nhắn của AI vào UI (Sử dụng TTexts hoàn toàn)
      messages.add(ChatMessage(
          text: "${TTexts.chatbotMockResponse.tr} '$text'", isUser: false));
    } catch (e) {
      // 🟢 CHUYỀN LỖI CHO MIXIN XỬ LÝ: Nó sẽ tự bóc tách mã lỗi và hiện Snackbar
      handleError(e);
    } finally {
      // 5. Tắt trạng thái đang gõ
      isTyping.value = false;
      _scrollToBottom();
    }
  }

  // Hàm tự động cuộn xuống cuối cùng khi có tin nhắn mới
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
