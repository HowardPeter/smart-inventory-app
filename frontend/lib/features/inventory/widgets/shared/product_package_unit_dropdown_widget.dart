import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend/core/infrastructure/constants/text_strings.dart';
import 'package:frontend/core/ui/theme/app_colors.dart';
import 'package:frontend/core/ui/theme/app_sizes.dart';
import 'package:frontend/core/ui/widgets/t_text_form_field_widget.dart';
import 'package:frontend/features/inventory/controllers/product_form_controller.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ProductPackageUnitDropdownWidget extends StatefulWidget {
  const ProductPackageUnitDropdownWidget({super.key});

  @override
  State<ProductPackageUnitDropdownWidget> createState() =>
      _ProductPackageUnitDropdownWidgetState();
}

class _ProductPackageUnitDropdownWidgetState
    extends State<ProductPackageUnitDropdownWidget>
    with SingleTickerProviderStateMixin {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    // Hiệu ứng xổ xuống (SizeTransition)
    _animation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }

    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
    _animationController.forward();
  }

  void _closeDropdown() {
    _animationController.reverse().then((_) {
      // ĐÃ FIX: Chỉ xóa overlay và gọi setState nếu Widget CÒN SỐNG
      if (mounted) {
        _removeOverlay();
      }
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    final controller = Get.find<ProductFormController>();

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Lớp nền vô hình để bấm ra ngoài thì đóng menu
          GestureDetector(
            onTap: _closeDropdown,
            behavior: HitTestBehavior.translucent,
            child: Container(color: Colors.transparent),
          ),

          // Dính chặt menu vào ô input
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 8), // Cách ô input 8px xuống dưới
            child: Material(
              color: Colors.transparent,
              child: SizeTransition(
                sizeFactor: _animation,
                axisAlignment: -1, // Mở từ trên xuống
                child: Container(
                  width: size.width,
                  constraints: const BoxConstraints(
                      maxHeight: 250), // Chiều cao tối đa của menu
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radius16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 20, sigmaY: 20), // Tăng độ mờ
                      child: Container(
                        decoration: BoxDecoration(
                          // ĐÃ SỬA: DÙNG GRADIENT TRONG SUỐT ĐỂ TẠO KÍNH MỜ CHUẨN
                          gradient: LinearGradient(
                            colors: [
                              Colors.white
                                  .withOpacity(0.6), // Sáng bóng ở góc trên
                              Colors.white
                                  .withOpacity(0.15), // Trong suốt ở góc dưới
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radius16),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.7), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10))
                          ],
                        ),
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: controller.mockUnits.length,
                          separatorBuilder: (_, __) => Divider(
                              height: 1, color: Colors.white.withOpacity(0.3)),
                          itemBuilder: (context, index) {
                            final unit = controller.mockUnits[index];
                            return InkWell(
                              onTap: () {
                                controller.selectedUnitId.value = unit['id']!;
                                _closeDropdown();
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(unit['name']!,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            color: AppColors.primaryText,
                                            fontWeight: FontWeight.w600)),
                                    Text(unit['code']!,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductFormController>();

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: AbsorbPointer(
          child: Obx(() {
            final selectedUnit = controller.mockUnits.firstWhereOrNull(
                (u) => u['id'] == controller.selectedUnitId.value);
            return TTextFormFieldWidget(
              label: TTexts.unitLabel.tr,
              hintText: TTexts.selectUnit.tr,
              controller:
                  TextEditingController(text: selectedUnit?['name'] ?? ''),
              suffixIcon: AnimatedRotation(
                turns: _isOpen ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(Iconsax.arrow_down_1_copy,
                    size: 20, color: AppColors.primary),
              ),
            );
          }),
        ),
      ),
    );
  }
}
