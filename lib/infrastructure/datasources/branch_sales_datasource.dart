import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/api_handler.dart';
import 'package:tuvalapp/config/http/endpoints/sales_endpoints.dart';
import 'package:tuvalapp/infrastructure/models/sales/branch_sales.dart';

class BranchSalesDatasource {
  const BranchSalesDatasource({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<List<BranchSales>> list(DateTime from, DateTime to) async {
    String date(DateTime value) => value.toIso8601String().split('T').first;

    final result = await ApiHandler.run(
      () => _dio.get(
        SalesEndpoints.branchSalesComparison,
        queryParameters: {'FechaIni': date(from), 'FechaFin': date(to)},
        options: Options(extra: {'requiresAuth': true}),
      ),
    );
    final data = result['data'];
    if (data is! List) throw const FormatException('Listado inválido');
    return data
        .map(
          (row) => BranchSales.fromJson(Map<String, dynamic>.from(row as Map)),
        )
        .toList(growable: false);
  }
}
