import 'package:flutter/material.dart';
import 'package:tuvalapp/infrastructure/datasources/point_sales_datasource.dart';
import 'package:tuvalapp/infrastructure/models/point_sales/point_sale_model.dart';
import 'package:tuvalapp/infrastructure/services/key_value_storage_service.dart';

class PointSalesProvider extends ChangeNotifier {
  final PointSalesDatasource pointSalesDatasource;
  final KeyValueStorageService keyValueStorageService;

  PointSalesProvider({
    required this.pointSalesDatasource,
    required this.keyValueStorageService,
  });

  static const String selectedPointSaleKey = 'selected_point_sale_id';
  int _generation = 0;
  bool _disposed = false;
  Future<void> _storageQueue = Future<void>.value();

  // Serialize writes and logout cleanup, including writes already in flight.
  Future<void> _persist(Future<void> Function() action) {
    final operation = _storageQueue.then((_) => action());
    _storageQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  bool _current(int generation) => !_disposed && generation == _generation;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  bool isLoading = false;
  String? errorMessage;
  int? pvDefault;
  List<PointSaleModel> pointSales = [];
  PointSaleModel? selectedPointSale;
  int? get selectedPvId => selectedPointSale?.pvId;
  String get selectedPvCode => selectedPointSale?.pvCode ?? '';
  String get selectedPvDescription =>
      selectedPointSale?.pvDescription ?? 'Sin punto de venta';

  bool get hasPointSaleSelected => selectedPointSale != null;

  Future<void> loadPointSales({bool force = false}) async {
    if (isLoading || _disposed) return;

    if (!force && pointSales.isNotEmpty && selectedPointSale != null) {
      return;
    }
    final generation = _generation;
    try {
      isLoading = true;
      errorMessage = null;
      _notify();

      final response = await pointSalesDatasource.getPointSalesMobile();
      if (!_current(generation)) return;
      await _storageQueue;
      if (!_current(generation)) return;

      final storedPvIdValue = await keyValueStorageService.getKeyValue<String>(
        selectedPointSaleKey,
      );
      if (!_current(generation)) return;
      pvDefault = response.pvDefault;
      pointSales = response.pvList;

      final storedPvId = storedPvIdValue == null
          ? null
          : int.tryParse(storedPvIdValue);

      selectedPointSale = _resolveInitialPointSale(storedPvId);

      if (selectedPointSale != null) {
        await _saveSelectedPointSale(selectedPointSale!.pvId, generation);
      }
    } catch (e) {
      if (_current(generation)) {
        errorMessage = 'No se pudo cargar los puntos de venta.';
      }
    } finally {
      if (_current(generation)) {
        isLoading = false;
        _notify();
      }
    }
  }

  PointSaleModel? _resolveInitialPointSale(int? storedPvId) {
    PointSaleModel? selected;

    if (storedPvId != null) {
      selected = _findPointSaleById(storedPvId);
    }

    selected ??= _findDefaultPointSale();

    selected ??= _findPointSaleById(pvDefault);

    selected ??= pointSales.isNotEmpty ? pointSales.first : null;

    return selected;
  }

  PointSaleModel? _findPointSaleById(int? pvId) {
    if (pvId == null) return null;

    try {
      return pointSales.firstWhere((pointSale) => pointSale.pvId == pvId);
    } catch (_) {
      return null;
    }
  }

  PointSaleModel? _findDefaultPointSale() {
    try {
      return pointSales.firstWhere((pointSale) => pointSale.isDefault);
    } catch (_) {
      return null;
    }
  }

  Future<void> changePointSale(PointSaleModel pointSale) async {
    if (_disposed) return;
    final generation = _generation;
    selectedPointSale = pointSale;
    _notify();
    await _saveSelectedPointSale(pointSale.pvId, generation);
  }

  Future<void> clearPointSales() async {
    _generation++;
    isLoading = false;
    pvDefault = null;
    pointSales = [];
    selectedPointSale = null;
    errorMessage = null;

    _notify();
    await _persist(
      () => keyValueStorageService.removeKey(selectedPointSaleKey),
    );
  }

  Future<void> _saveSelectedPointSale(int pvId, int generation) =>
      _persist(() async {
        if (!_current(generation)) return;
        await keyValueStorageService.setKeyValue<String>(
          selectedPointSaleKey,
          pvId.toString(),
        );
      });

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
