import 'package:tuvalapp/infrastructure/models/point_sales/point_sale_model.dart';

class PointSalesResponse {
  final int? pvDefault;
  final List<PointSaleModel> pvList;

  PointSalesResponse({required this.pvDefault, required this.pvList});

  factory PointSalesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return PointSalesResponse(
      pvDefault: data['pv_default'] == null
          ? null
          : int.tryParse(data['pv_default'].toString()),
      pvList: (data['pv_list'] as List<dynamic>? ?? [])
          .map((item) => PointSaleModel.fromJson(item))
          .toList(),
    );
  }
}
