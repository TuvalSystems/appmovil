class PointSaleModel {
  final int pvId;
  final String pvCode;
  final String pvDescription;
  final bool isDefault;

  PointSaleModel({
    required this.pvId,
    required this.pvCode,
    required this.pvDescription,
    this.isDefault = false,
  });

  factory PointSaleModel.fromJson(Map<String, dynamic> json) {
    return PointSaleModel(
      pvId: int.parse(json['pv_id'].toString()),
      pvCode: json['pv_code']?.toString() ?? '',
      pvDescription: json['pv_descripcion']?.toString() ?? '',
      isDefault:
          json['is_default'] == true || json['is_default']?.toString() == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pv_id': pvId,
      'pv_code': pvCode,
      'pv_descripcion': pvDescription,
      'is_default': isDefault,
    };
  }
}
