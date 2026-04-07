import 'package:get/get.dart';

class ProfileAssignsRoleController extends GetxController {
  var selectedIndex = 0.obs;
  var isLoading = true.obs;

  // Sử dụng Map<String, dynamic> để dễ quản lý dữ liệu hơn dynamic lẻ
  var allUsers = <Map<String, dynamic>>[].obs;
  var filteredUsers = <Map<String, dynamic>>[].obs;

  int get totalCount => filteredUsers.length;

  @override
  void onInit() {
    super.onInit();
    fetchUsersFromApi();
  }

  Future<void> fetchUsersFromApi() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

      // Thêm ID để định danh user chính xác khi update
      List<Map<String, dynamic>> mockData = [
        {'id': '1', 'name': 'Tran Hoa Tuyet Lap', 'role': 'Owner'},
        {'id': '2', 'name': 'Nam Nguyen', 'role': 'Manager'},
        {'id': '3', 'name': 'Mai Linh', 'role': 'Manager'},
        {'id': '4', 'name': 'Bao Le', 'role': 'Staff'},
      ];

      allUsers.assignAll(mockData);
      applyFilter();
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedIndex.value = index;
    applyFilter();
  }

  // --- HÀM UPDATE ROLE ---
  void updateRole(String userId, String newRole) {
    // 1. Tìm vị trí user trong danh sách gốc
    int index = allUsers.indexWhere((user) => user['id'] == userId);

    if (index != -1) {
      // 2. Cập nhật giá trị mới
      allUsers[index]['role'] = newRole;

      // 3. Refresh danh sách để GetX nhận diện sự thay đổi bên trong mảng Map
      allUsers.refresh();

      // 4. Lọc lại để UI cập nhật ngay lập tức (nếu đang ở tab lọc theo role đó)
      applyFilter();

      // TODO: Gọi API update lên server tại đây
      // await repository.updateUserRole(userId, newRole);
    }
  }

  void applyFilter() {
    if (selectedIndex.value == 0) {
      filteredUsers.assignAll(allUsers);
    } else {
      String roleTarget = "";
      if (selectedIndex.value == 1) roleTarget = "Owner";
      if (selectedIndex.value == 2) roleTarget = "Manager";
      if (selectedIndex.value == 3) roleTarget = "Staff";

      filteredUsers.assignAll(
        allUsers.where((user) => user['role'] == roleTarget).toList(),
      );
    }
  }
}
