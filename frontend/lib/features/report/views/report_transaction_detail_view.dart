import 'package:flutter/material.dart';
import 'package:frontend/core/ui/layouts/t_responsive_layout.dart';
import 'package:frontend/features/report/views/platform/report_mobile_view.dart';

class ReportTransactionDetailView extends StatelessWidget {
  const ReportTransactionDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TResponsiveLayout(mobile: ReportMobileView()),
    );
  }
}
