import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/api_handler.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/config/http/endpoints/auth_endpoints.dart';
import 'package:tuvalapp/infrastructure/models/point_sales/point_sales_response.dart';

class PointSalesDatasource {
  final Dio _dio;

  PointSalesDatasource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<PointSalesResponse> getPointSalesMobile() async {
    final response = await ApiHandler.run(() {
      return _dio.get(
        AuthEndpoints.pointSales,
        options: Options(extra: {'requiresAuth': true}),
      );
    });
    return PointSalesResponse.fromJson(response);
  }
}
