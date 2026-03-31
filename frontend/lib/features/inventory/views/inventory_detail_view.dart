import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/inventory/views/platform/inventory_detail_mobile_view.dart';

class InventoryDetailView extends StatelessWidget {
  const InventoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: InventoryDetailMobileView()),
    );
  }
}
