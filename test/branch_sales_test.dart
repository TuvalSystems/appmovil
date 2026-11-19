import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvalapp/infrastructure/datasources/branch_sales_datasource.dart';
import 'package:tuvalapp/infrastructure/models/sales/branch_sales.dart';
import 'package:tuvalapp/presentation/screens/sales/branch_sales/providers/branch_sales_provider.dart';

Map<String, dynamic> fixture(num? sales, num? cost) => {
  'txNom': ' Sucursal de prueba ',
  for (final period in SalesPeriod.values) ...{
    period.salesKey: sales,
    period.costKey: cost,
  },
};

void main() {
  test('preserva signo, decimales, nulos y ceros', () {
    final branch = BranchSales.fromJson(fixture(-12.5, null));
    expect(branch.name, 'Sucursal de prueba');
    expect(branch.periods[SalesPeriod.today], (sales: -12.5, cost: null));
    final zero = BranchSales.fromJson(fixture(0, null));
    expect(BranchSales.total([zero], SalesPeriod.today), (
      sales: 0,
      cost: null,
    ));
    expect(BranchSales.total([branch, zero], SalesPeriod.today), (
      sales: -12.5,
      cost: null,
    ));
  });

  test('envía fechas ISO por GET autenticado sin limitar sucursales', () async {
    final dio = Dio();
    addTearDown(dio.close);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          expect(request.method, 'GET');
          expect(request.path, '/movil/reportes/ventas/sucursales/comparativo');
          expect(request.extra['requiresAuth'], true);
          expect(request.queryParameters, {
            'FechaIni': '2026-02-01',
            'FechaFin': '2026-02-08',
          });
          handler.resolve(
            Response<dynamic>(
              requestOptions: request,
              data: {
                'success': true,
                'data': [fixture(10, 5)],
              },
            ),
          );
        },
      ),
    );
    final result = await BranchSalesDatasource(
      dio: dio,
    ).list(DateTime(2026, 2, 1), DateTime(2026, 2, 8));
    expect(result.single.periods[SalesPeriod.selected], (sales: 10, cost: 5));
  });

  test('un error puede reintentarse y no se confunde con vacío', () async {
    final dio = Dio();
    addTearDown(dio.close);
    var calls = 0;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          calls++;
          handler.resolve(
            Response<dynamic>(
              requestOptions: request,
              data: {'success': calls == 2, 'data': <dynamic>[]},
            ),
          );
        },
      ),
    );
    final provider = BranchSalesProvider(BranchSalesDatasource(dio: dio));
    addTearDown(provider.dispose);
    final date = DateTime(2026, 2, 1);
    await provider.load(date, date);
    expect(provider.error, isNotNull);
    await provider.load(date, date);
    expect(provider.error, isNull);
    expect(provider.rows, isEmpty);
    expect(provider.hasSearched, true);
  });
}
