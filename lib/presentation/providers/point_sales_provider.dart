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
    if (isLoading) return;

    if (!force && pointSales.isNotEmpty && selectedPointSale != null) {
      return;
    }
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final response = await pointSalesDatasource.getPointSalesMobile();

      pvDefault = response.pvDefault;
      pointSales = response.pvList;

      final storedPvIdValue = await keyValueStorageService.getKeyValue<String>(
        selectedPointSaleKey,
      );

      final storedPvId = storedPvIdValue == null
          ? null
          : int.tryParse(storedPvIdValue);

      selectedPointSale = _resolveInitialPointSale(storedPvId);

      if (selectedPointSale != null) {
        await _saveSelectedPointSale(selectedPointSale!.pvId);
      }
    } catch (e) {
      errorMessage = 'No se pudo cargar los puntos de venta.';
    } finally {
      isLoading = false;
      notifyListeners();
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
    selectedPointSale = pointSale;

    await _saveSelectedPointSale(pointSale.pvId);

    notifyListeners();
  }

  Future<void> clearPointSales() async {
    pvDefault = null;
    pointSales = [];
    selectedPointSale = null;
    errorMessage = null;

    await keyValueStorageService.removeKey(selectedPointSaleKey);

    notifyListeners();
  }

  Future<void> _saveSelectedPointSale(int pvId) async {
    await keyValueStorageService.setKeyValue<String>(
      selectedPointSaleKey,
      pvId.toString(),
    );
  }
}
