import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/transaction/views/platform/stock_adjustment_mobile_view.dart';

class StockAdjustmentView extends StatelessWidget {
  const StockAdjustmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: StockAdjustmentMobileView()),
    );
  }
}
