class StoreModel {
  final String storeId;
  final String name;
  final String address;
  final String activeStatus;

  StoreModel(
      {required this.storeId,
      required this.name,
      required this.address,
      required this.activeStatus});

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      storeId: json['store_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      activeStatus: json['active_status'] ?? '',
    );
  }
}
