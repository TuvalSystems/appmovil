import 'package:flutter/foundation.dart';
import 'package:tuvalapp/config/http/api_exception.dart';
import 'package:tuvalapp/infrastructure/datasources/branch_sales_datasource.dart';
import 'package:tuvalapp/infrastructure/models/sales/branch_sales.dart';

class BranchSalesProvider extends ChangeNotifier {
  BranchSalesProvider(this._datasource);

  final BranchSalesDatasource _datasource;
  bool _disposed = false;
  bool isLoading = false;
  bool hasSearched = false;
  String? error;
  List<BranchSales> rows = const [];

  Future<void> load(DateTime from, DateTime to) async {
    if (_disposed || isLoading) return;
    isLoading = true;
    hasSearched = true;
    error = null;
    rows = const [];
    notifyListeners();
    try {
      final result = await _datasource.list(from, to);
      if (!_disposed) rows = result;
    } on ApiException catch (exception) {
      if (!_disposed) {
        error = exception.status == 403
            ? 'No tiene permiso para consultar este listado.'
            : exception.message;
      }
    } catch (_) {
      if (!_disposed) error = 'No se pudo consultar el listado de ventas.';
    } finally {
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void clear() {
    hasSearched = false;
    rows = const [];
    error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
