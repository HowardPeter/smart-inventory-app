import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileAssignsRoleController extends GetxController {
  final searchController = TextEditingController();

  var selectedIndex = 0.obs;
  var isLoading = true.obs;
  var searchQuery = "".obs;

  var allUsers = <Map<String, dynamic>>[].obs;
  var filteredUsers = <Map<String, dynamic>>[].obs;

  int get totalCount => filteredUsers.length;

  @override
  void onInit() {
    super.onInit();
    fetchUsersFromApi();
  }

  // 2. Hàm xử lý khi người dùng gõ chữ
  void onSearchChanged(String value) {
    searchQuery.value = value;
    applyFilter();
  }

  // 3. Hàm Clear Search dùng cho cả nút X và nút Clear ở trang trống
  void clearSearch() {
    searchController.clear();
    searchQuery.value = "";
    applyFilter();
  }

  void applyFilter() {
    List<Map<String, dynamic>> results = [];

    // Bước 1: Lọc theo Tab (Role)
    if (selectedIndex.value == 0) {
      results = List.from(allUsers);
    } else {
      String roleTarget = "";
      if (selectedIndex.value == 1) roleTarget = "Owner";
      if (selectedIndex.value == 2) roleTarget = "Manager";
      if (selectedIndex.value == 3) roleTarget = "Staff";

      results = allUsers.where((user) => user['role'] == roleTarget).toList();
    }

    // Bước 2: Lọc tiếp theo Tên (Search Query)
    if (searchQuery.value.isNotEmpty) {
      results = results.where((user) {
        final name = user['name'].toString().toLowerCase();
        final query = searchQuery.value.toLowerCase();
        return name.contains(query);
      }).toList();
    }

    filteredUsers.assignAll(results);
  }

  Future<void> fetchUsersFromApi() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1));

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

  void updateRole(String userId, String newRole) {
    final userIndex = allUsers.indexWhere((user) => user['id'] == userId);
    if (userIndex != -1) {
      allUsers[userIndex]['role'] = newRole;
      allUsers.refresh();
      applyFilter();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
