import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/inventory/views/platform/product_catalog_mobile_view.dart';

class ProductCatalogView extends StatelessWidget {
  const ProductCatalogView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: ProductCatalogMobileView()),
    );
  }
}
