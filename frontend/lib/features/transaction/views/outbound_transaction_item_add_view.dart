import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/transaction/views/platform/outbound_transaction_item_add_mobile_view.dart';

class OutboundTransactionItemAddView extends StatelessWidget {
  const OutboundTransactionItemAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: OutboundTransactionItemAddMobileView()),
    );
  }
}
