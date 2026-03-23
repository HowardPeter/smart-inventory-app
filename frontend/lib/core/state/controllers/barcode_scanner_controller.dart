import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerController extends GetxController {
  // Pattern Singleton của GetX để dễ dàng gọi ở mọi nơi: BarcodeScannerController.instance...
  static BarcodeScannerController get instance => Get.find();

  // Khởi tạo máy quét
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed:
        DetectionSpeed.noDuplicates, // Chống quét lặp liên tục một mã
    formats: [BarcodeFormat.all],
  );

  // Trạng thái Rx để UI tự động cập nhật
  final RxBool isPaused = false.obs;
  final RxnString scannedCode = RxnString(null);

  @override
  void onClose() {
    // Đảm bảo giải phóng camera khi Controller bị huỷ
    cameraController.dispose();
    super.onClose();
  }

  // Hàm xử lý khi camera bắt được mã
  void onDetect(
      BarcodeCapture capture, Function(String code)? onScannedCallback) {
    if (isPaused.value) return; // Nếu đang tạm dừng thì bỏ qua

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        // 1. Cập nhật trạng thái
        scannedCode.value = barcode.rawValue;
        isPaused.value = true; // Lập tức dừng quét để xử lý mã này

        // 2. Gọi callback trả về cho UI nếu có
        if (onScannedCallback != null) {
          onScannedCallback(barcode.rawValue!);
        }
        break;
      }
    }
  }

  // Hàm để UI hoặc các service khác gọi khi muốn tiếp tục quét mã mới
  void resumeScan() {
    isPaused.value = false;
    scannedCode.value = null;
  }

  // Hàm chủ động tạm dừng quét (Ví dụ: khi đang call API kiểm tra mã)
  void pauseScan() {
    isPaused.value = true;
  }
}
