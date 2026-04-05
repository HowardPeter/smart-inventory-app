import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_controller.dart';
import 'package:get/get.dart';

class StockAdjustmentAdditionalNoteWidget
    extends GetView<StockAdjustmentController> {
  const StockAdjustmentAdditionalNoteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final notes = controller.combinedItemNotes;
          if (notes.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.softGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(TTexts.combinedNotesTitle.tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primaryText)),
                const SizedBox(height: 8),
                Text(notes,
                    style: const TextStyle(
                        fontSize: 13, height: 1.5, color: AppColors.subText)),
              ],
            ),
          );
        }),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: TTextFormFieldWidget(
            label: TTexts.additionalNote.tr,
            hintText: TTexts.specificNoteHint.tr,
            controller: controller.additionalNoteController,
            maxLines: 3,
            prefixIcon: Icons.edit_note_rounded,
          ),
        ),
      ],
    );
  }
}
