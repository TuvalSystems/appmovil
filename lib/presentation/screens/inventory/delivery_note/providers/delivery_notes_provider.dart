import 'package:tuvalapp/presentation/shared/controllers/customer_search_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:tuvalapp/infrastructure/datasources/delivery_notes_datasource.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note.dart';

class DeliveryNotesProvider extends ChangeNotifier {
  final DeliveryNotesDatasource datasource;
  DeliveryNotesProvider({DeliveryNotesDatasource? datasource})
    : datasource = datasource ?? DeliveryNotesDatasource() {
    customerSearch.onCustomerChanged = _onCustomerChanged;
  }

  final customerSearch = CustomerSearchController();

  void _onCustomerChanged() {
    final selected = customerSearch.selectedCustomer;
    if (customer?.id == selected?.id) return;
    changeCustomer(
      selected == null
          ? null
          : DeliveryNoteCustomer(
              selected.id,
              selected.razonSocial,
              selected.ruc,
            ),
    );
  }

  List<DeliveryNoteOption> types = [];
  List<DeliveryNoteOption> warehouses = [];
  List<DeliveryNote> items = [];
  String? type;
  int? pointSaleId;
  int? originWarehouseId;
  DeliveryNoteCustomer? customer;
  bool initializing = false;
  bool loading = false;
  bool loadingMore = false;
  String? error;
  String? catalogError;
  int page = 0;
  int lastPage = 0;
  int total = 0;
  int _generation = 0;
  bool _disposed = false;
  bool get isDispatch => type == 'despacho';
  bool get hasMore => page < lastPage;
  bool get ready =>
      !initializing &&
      catalogError == null &&
      type != null &&
      pointSaleId != null;

  Future<void> initialize(int? activePointSaleId) async {
    initializing = true;
    catalogError = null;
    pointSaleId = activePointSaleId;
    _notify();
    try {
      final result = await Future.wait([
        datasource.types(),
        datasource.warehouses(),
      ]);
      if (_disposed) return;
      types = result[0];
      warehouses = result[1];
      type = types.isEmpty ? null : types.first.id;
      if (types.isEmpty) catalogError = 'No hay tipos de guías disponibles.';
    } catch (e) {
      if (_disposed) return;
      catalogError = e.toString();
    } finally {
      initializing = false;
      _notify();
    }
    if (!_disposed && ready) await refresh();
  }

  Future<void> changeType(String value) async {
    if (type == value) return;
    type = value;
    originWarehouseId = null;
    customer = null;
    customerSearch.clearSelectedCustomer();
    await refresh();
  }

  Future<void> changePointSale(int? value) async {
    pointSaleId = value;
    await refresh();
  }

  Future<void> changeOriginWarehouse(int? value) async {
    originWarehouseId = value;
    await refresh();
  }

  Future<void> changeCustomer(DeliveryNoteCustomer? value) async {
    customer = value;
    await refresh();
  }

  Future<void> refresh() async {
    final generation = ++_generation;
    items = [];
    page = 0;
    lastPage = 0;
    total = 0;
    error = null;
    loadingMore = false;
    loading = ready;
    _notify();
    if (!ready) return;
    await _fetch(1, generation);
  }

  Future<void> loadMore() async {
    if (!ready || loading || loadingMore || !hasMore) return;
    loadingMore = true;
    error = null;
    _notify();
    await _fetch(page + 1, _generation);
  }

  Future<void> _fetch(int requestedPage, int generation) async {
    try {
      final result = await datasource.list(
        type: type!,
        pointSaleId: pointSaleId!,
        originWarehouseId: isDispatch ? null : originWarehouseId,
        customerId: isDispatch ? customer?.id : null,
        page: requestedPage,
      );
      if (_disposed || generation != _generation) return;
      items = requestedPage == 1 ? result.items : [...items, ...result.items];
      page = result.page;
      lastPage = result.lastPage;
      total = result.total;
    } catch (e) {
      if (_disposed || generation != _generation) return;
      error = e.toString();
    } finally {
      if (!_disposed && generation == _generation) {
        loading = false;
        loadingMore = false;
        _notify();
      }
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    customerSearch.dispose();
    super.dispose();
  }
}
