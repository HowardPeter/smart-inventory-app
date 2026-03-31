import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class TExpandableFabWidget extends StatefulWidget {
  final VoidCallback onManualAdd;
  final VoidCallback onScanAdd;
  final bool isStaffMode; // 🟢 THÊM CỜ PHÂN QUYỀN VÀO ĐÂY

  const TExpandableFabWidget({
    super.key,
    required this.onManualAdd,
    required this.onScanAdd,
    this.isStaffMode = false, // Mặc định là Quản lý
  });

  @override
  State<TExpandableFabWidget> createState() => _TExpandableFabWidgetState();
}

class _TExpandableFabWidgetState extends State<TExpandableFabWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _expandAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ==============================================================
    // 🟢 NẾU LÀ STAFF: HIỆN NÚT ĐƠN TRÔNG Y HỆT NÚT GỐC NHƯNG ĐỂ QUÉT
    // ==============================================================
    if (widget.isStaffMode) {
      return SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          heroTag: "fab_scan_staff",
          shape: const CircleBorder(),
          backgroundColor: Colors.black, // Giữ màu đen đồng bộ
          elevation: 6,
          onPressed: widget.onScanAdd, // Bấm là gọi hàm Scan luôn
          child: const Icon(Iconsax.scan_barcode_copy,
              color: Colors.white, size: 28),
        ),
      );
    }

    // ==============================================================
    // 🟢 NẾU LÀ MANAGER: HIỆN LOGIC BUNG NÚT NHƯ CŨ
    // ==============================================================
    return SizedBox(
      width: 56,
      height: 220,
      child: AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // --- Nút Scan ---
              Positioned(
                bottom: 140 * _expandAnimation.value,
                child: Transform.scale(
                  scale: _expandAnimation.value,
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: FloatingActionButton(
                        heroTag: "fab_scan",
                        shape: const CircleBorder(),
                        backgroundColor: const Color(0xFF1E1E24),
                        elevation: 4,
                        onPressed: () {
                          _toggle();
                          widget.onScanAdd();
                        },
                        child: const Icon(Iconsax.scan_barcode_copy,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ),

              // --- Nút Manual ---
              Positioned(
                bottom: 75 * _expandAnimation.value,
                child: Transform.scale(
                  scale: _expandAnimation.value,
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: FloatingActionButton(
                        heroTag: "fab_manual",
                        shape: const CircleBorder(),
                        backgroundColor: const Color(0xFF1E1E24),
                        elevation: 4,
                        onPressed: () {
                          _toggle();
                          widget.onManualAdd();
                        },
                        child: const Icon(Iconsax.edit_2_copy,
                            color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ),

              // --- Nút Chính ---
              Positioned(
                bottom: 0,
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: FloatingActionButton(
                    heroTag: "fab_main",
                    shape: const CircleBorder(),
                    backgroundColor:
                        _isOpen ? const Color(0xFF1E1E24) : Colors.black,
                    elevation: 6,
                    onPressed: _toggle,
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0.0, end: 0.125)
                          .animate(_controller),
                      child:
                          const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
