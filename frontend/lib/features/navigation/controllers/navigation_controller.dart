import 'package:frontend/core/state/services/store_service.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  static NavigationController get instance => Get.find();

  final RxInt selectedIndex = 0.obs;

  final StoreService _storeService = Get.find<StoreService>();

  bool get isRestricted =>
      _storeService.currentRole.value.toLowerCase() == 'staff';

  void changeIndex(int index) {
    // Nếu là nhân viên (restricted) mà cố gắng bấm vào Home(0) hoặc Report(3) -> Chặn
    if (isRestricted && (index == 0 || index == 3)) {
      selectedIndex.value = 1;
    } else {
      selectedIndex.value = index;
    }
  }

  void enforceRoleRestrictions() {
    if (isRestricted &&
        (selectedIndex.value == 0 || selectedIndex.value == 3)) {
      changeIndex(1);
    }
  }
}
