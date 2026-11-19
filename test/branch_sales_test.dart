import 'package:flutter/material.dart';
import 'package:tuvalapp/presentation/screens/sales/branch_sales/branch_sales_screen.dart';
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
  test('no presenta sumas parciales ni GM sin importes suficientes', () {
    final period = SalesPeriod.today;
    final complete = BranchSales.fromJson(fixture(10, 5));
    final partial = BranchSales.fromJson(fixture(null, 1));
    final totals = BranchSales.total([complete, partial], period);
    expect(totals, (sales: null, cost: null));
    expect(BranchSales.grossMargin(totals), isNull);
    expect(BranchSales.grossMargin((sales: 0, cost: 1)), isNull);
    expect(BranchSales.grossMargin((sales: 10, cost: null)), isNull);
    expect(BranchSales.grossMargin((sales: 10, cost: 5)), 0.5);
  });

  test('los pares NULL/NULL no descartan importes de otras sucursales', () {
    final period = SalesPeriod.today;
    final informed = BranchSales.fromJson(fixture(100, 75));
    final absent = BranchSales.fromJson(fixture(null, null));
    final adjustment = BranchSales.fromJson(fixture(-20, -15));
    final totals = BranchSales.total([informed, absent, adjustment], period);
    expect(totals, (sales: 80, cost: 60));
    expect(BranchSales.grossMargin(totals), 0.25);
    expect(BranchSales.total([absent], period), (sales: null, cost: null));
    final missingCost = BranchSales.fromJson(fixture(50, null));
    expect(BranchSales.total([informed, missingCost], period), (
      sales: 150,
      cost: null,
    ));
  });

  testWidgets('mantiene Sucursal al desplazar importes en móvil', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BranchSalesTable(
            rows: [BranchSales.fromJson(fixture(-12.50, -5))],
          ),
        ),
      ),
    );
    final label = find.text('Sucursal');
    final position = tester.getTopLeft(label);
    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('GM (%)'), findsOneWidget);
    expect(find.text(r'$-12.50'), findsWidgets);
    final scroll = find.byKey(const ValueKey('branch-sales-periods'));
    await tester.drag(scroll, const Offset(-450, 0));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(label), position);
    expect(tester.takeException(), isNull);
  });

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
