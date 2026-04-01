import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/inventory/views/platform/inventory_insight_mobile_view.dart';

class InventoryInsightView extends StatelessWidget {
  const InventoryInsightView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: InventoryInsightMobileView()),
    );
  }
}
