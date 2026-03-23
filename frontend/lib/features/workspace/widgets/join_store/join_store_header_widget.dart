// lib/features/workspace/widgets/join_store/join_store_header_widget.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';

class JoinStoreHeaderWidget extends StatelessWidget {
  const JoinStoreHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TIÊU ĐỀ
        Text(
          TTexts.joinWorkspaceTitle.tr,
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryText),
        ),
        const SizedBox(height: 8),
        // PHỤ ĐỀ
        Text(
          TTexts.joinWorkspaceSubtitle.tr,
          style: const TextStyle(
              fontSize: 15, color: AppColors.subText, height: 1.5),
        ),
      ],
    );
  }
}
