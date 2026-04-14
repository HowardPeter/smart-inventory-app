import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/infrastructure/utils/error_handler_utils.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/features/home/model/adjustment_history_model.dart';
import 'package:frontend/features/home/providers/home_provider.dart';
import 'package:frontend/core/ui/widgets/t_bottom_sheet_widget.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdjustmentHistoryController extends GetxController with TErrorHandler {
  final HomeProvider _provider = HomeProvider();

  final RxBool isLoading = true.obs;
  final RxBool isLoadMore = false.obs;
  final RxList<AdjustmentHistoryModel> logs = <AdjustmentHistoryModel>[].obs;

  final TextEditingController searchController = TextEditingController();
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  Timer? _debounce;

  int _currentPage = 1;
  final int _limit = 15;
  bool _hasMoreData = true;

  final Map<String, String> _nameDictionary = {};

  @override
  void onInit() {
    super.onInit();
    _initDictionaryAndFetchLogs();
  }

  @override
  void onClose() {
    searchController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  Future<void> _initDictionaryAndFetchLogs() async {
    try {
      final inventories = await _provider.getAllInventoriesForDictionary();
      for (var inv in inventories) {
        if (inv.productPackage != null) {
          _nameDictionary[inv.productPackageId] =
              inv.productPackage!.displayName;
          _nameDictionary[inv.inventoryId] = inv.productPackage!.displayName;
        }
      }
    } catch (e) {
      debugPrint("Lỗi Dictionary: $e");
    } finally {
      fetchLogs(isRefresh: true);
    }
  }

  Map<String, List<AdjustmentHistoryModel>> get groupedLogs {
    final Map<String, List<AdjustmentHistoryModel>> map = {};
    for (var log in logs) {
      final dateKey = DateFormat('yyyy-MM-dd').format(log.performedAt);
      if (!map.containsKey(dateKey)) {
        map[dateKey] = [];
      }
      map[dateKey]!.add(log);
    }
    return map;
  }

  Future<void> fetchLogs({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;

      logs.clear();
      isLoading.value = true;
    } else if (_currentPage == 1) {
      isLoading.value = true;
    } else {
      isLoadMore.value = true;
    }

    try {
      String? start, end;
      if (selectedDate.value != null) {
        final d = selectedDate.value!;
        start =
            DateTime(d.year, d.month, d.day, 0, 0, 0).toUtc().toIso8601String();
        end = DateTime(d.year, d.month, d.day, 23, 59, 59, 999)
            .toUtc()
            .toIso8601String();
      }

      final rawLogs = await _provider.getAuditLogs(
        page: _currentPage,
        limit: _limit, // CHỈ REQUEST 15 DÒNG
        search: searchController.text.trim(),
        startDate: start,
        endDate: end,
      );

      final List<AdjustmentHistoryModel> newLogs = [];

      for (var log in rawLogs) {
        dynamic oldRaw = log['oldValue'] ?? log['old_value'];
        dynamic newRaw = log['newValue'] ?? log['new_value'];

        Map<String, dynamic> oldVal = {};
        Map<String, dynamic> newVal = {};

        if (oldRaw is String) {
          try {
            oldVal = jsonDecode(oldRaw);
          } catch (_) {}
        } else if (oldRaw is Map) {
          oldVal = Map<String, dynamic>.from(oldRaw);
        }

        if (newRaw is String) {
          try {
            newVal = jsonDecode(newRaw);
          } catch (_) {}
        } else if (newRaw is Map) {
          newVal = Map<String, dynamic>.from(newRaw);
        }

        int oldQty = int.tryParse(oldVal['quantity']?.toString() ?? '0') ?? 0;
        int newQty = int.tryParse(newVal['quantity']?.toString() ?? '0') ?? 0;

        // DÒ TÊN SẢN PHẨM BẰNG TỪ ĐIỂN
        String pName = '';
        final String? pkgId = newVal['productPackageId']?.toString();
        final String? entityId =
            log['entity_id']?.toString() ?? log['entityId']?.toString();

        if (pkgId != null && _nameDictionary.containsKey(pkgId)) {
          pName = _nameDictionary[pkgId]!;
        } else if (entityId != null && _nameDictionary.containsKey(entityId)) {
          pName = _nameDictionary[entityId]!;
        } else {
          pName = log['note']?.toString().trim() ?? '';
          if (pName.isEmpty || pName == 'null') {
            pName = TTexts.systemAdjustment.tr;
          }
        }

        final dateStr = log['performedAt'] ??
            log['performed_at'] ??
            DateTime.now().toIso8601String();
        final id = log['id']?.toString() ??
            log['event_id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString();

        newLogs.add(AdjustmentHistoryModel(
          id: id,
          productName: pName,
          oldQuantity: oldQty,
          newQuantity: newQty,
          difference: newQty - oldQty,
          performedAt: DateTime.parse(dateStr).toLocal(),
          note: log['note']?.toString() ?? '',
        ));
      }

      if (newLogs.isEmpty || newLogs.length < _limit) {
        _hasMoreData = false;
      }

      if (isRefresh || _currentPage == 1) {
        logs.assignAll(newLogs);
      } else {
        logs.addAll(newLogs);
      }
      _currentPage++;
    } catch (e) {
      handleError(e);
    } finally {
      isLoading.value = false;
      isLoadMore.value = false;
    }
  }

  void onLoadMore() {
    if (_hasMoreData && !isLoadMore.value && !isLoading.value) {
      fetchLogs();
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      fetchLogs(isRefresh: true);
    });
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: Colors.orange)),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
      fetchLogs(isRefresh: true);
    }
  }

  void clearDateFilter() {
    selectedDate.value = null;
    fetchLogs(isRefresh: true);
  }

  String formatDateHeader(String yyyyMMdd) {
    final date = DateTime.parse(yyyyMMdd);
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return TTexts.today.tr;
    } else if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1) {
      return TTexts.yesterday.tr;
    }
    return DateFormat('dd MMMM yyyy').format(date);
  }

  void openDetails(AdjustmentHistoryModel model) {
    TBottomSheetWidget.show(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Icon Header To Tròn
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.softGrey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radius16),
            ),
            child: const Center(
              child: Text("🚙", style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          // 2. Title
          Text(
            TTexts.checkDetails.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 32),

          // 3. Nội dung tối giản như cũ
          _buildInfoRow(TTexts.productName.tr, model.productName),
          const SizedBox(height: 12),
          _buildInfoRow(TTexts.transactionDate.tr,
              DateFormat('dd MMM yyyy, HH:mm').format(model.performedAt)),
          const SizedBox(height: 12),
          _buildInfoRow(TTexts.qty.tr,
              "${model.oldQuantity} → ${model.newQuantity} (${model.difference > 0 ? '+' : ''}${model.difference})"),
          const SizedBox(height: 12),
          _buildInfoRow(
              TTexts.note.tr, model.note.isEmpty ? TTexts.na.tr : model.note),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, color: AppColors.subText)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText),
          ),
        ),
      ],
    );
  }
}
