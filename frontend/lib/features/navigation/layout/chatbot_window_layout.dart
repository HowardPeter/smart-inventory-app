import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/image_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/features/navigation/controllers/chatbot_ui_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:get/get.dart';

class ChatbotWindowLayout extends StatelessWidget {
  const ChatbotWindowLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    final footerBottomPadding =
        isKeyboardOpen ? 12.0 : (bottomSafe > 0 ? bottomSafe + 8.0 : 20.0);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, -5),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Column(
            children: [
              // --- CHAT HEADER ---
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
                color: AppColors.background,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        TImages.appLogos.appLogo,
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Trợ lý AI Storix",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF00C853),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                "Đang hoạt động",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.subText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.subText),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        Get.find<ChatbotUiController>().closeChat();
                      },
                    )
                  ],
                ),
              ),

              Container(height: 1, color: AppColors.divider.withOpacity(0.5)),

              // --- BODY (Khu vực tin nhắn lướt) ---
              Expanded(
                child: Container(
                  color: AppColors.surface,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(4),
                            ),
                            border: Border.all(
                                color: AppColors.divider.withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Text(
                            "Xin chào! Mình là trợ lý AI. Mình có thể giúp bạn kiểm tra tồn kho, tạo phiếu xuất/nhập hàng nhanh chóng. Bạn cần gì nào?",
                            style: TextStyle(
                                color: AppColors.primaryText,
                                fontSize: 14,
                                height: 1.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- FOOTER (Thanh nhập văn bản) ---
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, footerBottomPadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    )
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4, right: 12),
                      child: Icon(Iconsax.add_circle_copy,
                          color: AppColors.primary, size: 28),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const TextField(
                          maxLines: 4,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: "Nhập tin nhắn...",
                            hintStyle: TextStyle(
                                color: AppColors.subText, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 48,
                        width: 48,
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.send_1_copy,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
