class UnitModel {
  final String unitId;
  final String code;
  final String name;

  UnitModel({
    required this.unitId,
    required this.code,
    required this.name,
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      unitId: json['unitId'] ?? json['unit_id'] ?? json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? 'Unknown Unit',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unit_id': unitId,
      'code': code,
      'name': name,
    };
  }
}
