import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart'; // Thêm Error Handler
import 'package:frontend/core/ui/widgets/t_snackbars_widget.dart';
import 'package:frontend/features/transaction/controllers/stock_adjustment_controller.dart';
import 'package:frontend/features/transaction/models/adjustment_item_model.dart';
import 'package:get/get.dart';

class StockAdjustmentItemController extends GetxController with TErrorHandler {
  late final AdjustmentItemRx item;

  late RxInt tempActualQty;
  late RxString tempSelectedReason;
  late TextEditingController tempNoteController;

  final List<String> reasonOptions = [
    TTexts.damage,
    TTexts.expired,
    TTexts.loss,
    TTexts.itemFound,
    TTexts.inputError,
    TTexts.otherReason,
  ];

  @override
  void onInit() {
    super.onInit();
    try {
      if (Get.arguments is AdjustmentItemRx) {
        item = Get.arguments;
        _initializeFormData();
      } else {
        Get.back();
        TSnackbarsWidget.error(
            title: TTexts.errorTitle.tr, message: TTexts.errorLoadingData.tr);
      }
    } catch (e) {
      handleError(e);
    }
  }

  void _initializeFormData() {
    tempActualQty = item.actualQty.value.obs;
    tempSelectedReason = item.selectedReason.value.obs;
    tempNoteController = TextEditingController(text: item.note.value);
  }

  void incrementActualQty() {
    tempActualQty.value++;
    _updateAutomatedNote();
  }

  void decrementActualQty() {
    if (tempActualQty.value > 0) {
      tempActualQty.value--;
      _updateAutomatedNote();
    } else {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr,
          message: TTexts.notEnoughStockWarning.tr);
    }
  }

  void selectReason(String reasonKey) {
    if (tempActualQty.value == item.systemQty.value) {
      TSnackbarsWidget.warning(
          title: TTexts.warningTitle.tr,
          message: TTexts.noReasonNeededWarning.tr);
      return;
    }

    if (tempSelectedReason.value == reasonKey) {
      tempSelectedReason.value = '';
    } else {
      tempSelectedReason.value = reasonKey;
    }
    _updateAutomatedNote();
  }

  void _updateAutomatedNote() {
    if (tempActualQty.value == item.systemQty.value) {
      tempSelectedReason.value = '';
      tempNoteController.text = '';
      return;
    }

    if (tempSelectedReason.value.isNotEmpty) {
      final spread = tempActualQty.value - item.systemQty.value;
      final spreadStr = spread.abs().toString();

      final unitStr = item.packageInfo?.unit?.name ?? TTexts.defaultUnit.tr;
      final foundText = TTexts.itemFoundText.tr;

      String automatedText = "${tempSelectedReason.value.tr}: ";
      automatedText += spread > 0 ? "$foundText $spreadStr" : "-$spreadStr";
      automatedText +=
          " ${item.packageInfo?.displayName ?? item.name} $unitStr";

      tempNoteController.text = automatedText;
    } else {
      tempNoteController.text = '';
    }
  }

  int get spread => tempActualQty.value - item.systemQty.value;

  void confirmItemAdjustment() {
    item.actualQty.value = tempActualQty.value;
    item.selectedReason.value = tempSelectedReason.value;
    item.note.value = tempNoteController.text.trim();
    item.isChecked.value = true;

    if (Get.isRegistered<StockAdjustmentController>()) {
      Get.find<StockAdjustmentController>().filteredItems.refresh();
    }
    Get.back();
  }

  @override
  void onClose() {
    tempNoteController.dispose();
    super.onClose();
  }
}
