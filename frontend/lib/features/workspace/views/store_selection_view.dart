import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/workspace/views/platform/store_selection_mobile_view.dart';

class StoreSelectionView extends StatelessWidget {
  const StoreSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: TResponsiveLayout(mobile: StoreSelectionMobileView()),
    );
  }
}
