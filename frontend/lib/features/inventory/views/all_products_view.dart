import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/inventory/views/platform/all_products_mobile_view.dart';

class AllProductsView extends StatelessWidget {
  const AllProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: AllProductsMobileView()),
    );
    
  }
}