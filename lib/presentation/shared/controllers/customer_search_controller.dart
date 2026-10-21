import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tuvalapp/infrastructure/datasources/customers_datasource.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_customer.dart';

class CustomerSearchController extends ChangeNotifier {
  final CustomersDatasource datasource;
  CustomerSearchController({CustomersDatasource? datasource})
    : datasource = datasource ?? CustomersDatasource();

  final customerSearchController = TextEditingController();
  bool isSearchingCustomer = false;
  String? customerSearchMessage;
  SteamTrapCustomer? selectedCustomer;
  List<SteamTrapCustomer> customerResults = [];
  VoidCallback? onCustomerChanged;
  Timer? _debounce;
  int _generation = 0;
  bool _disposed = false;

  void onCustomerSearchChanged(String value) {
    _debounce?.cancel();
    _generation++;
    selectedCustomer = null;
    customerResults = [];
    customerSearchMessage = null;
    final query = value.trim();
    isSearchingCustomer = query.length >= 3;
    if (query.isNotEmpty && query.length < 3) {
      customerSearchMessage = 'Ingrese al menos 3 caracteres para buscar.';
    }
    onCustomerChanged?.call();
    notifyListeners();
    if (query.length >= 3) {
      _debounce = Timer(
        const Duration(milliseconds: 450),
        () => searchCustomers(query),
      );
    }
  }

  Future<void> searchCustomers(String query) async {
    _debounce?.cancel();
    final generation = ++_generation;
    final cleanQuery = query.trim();
    if (cleanQuery.length < 3) {
      customerResults = [];
      customerSearchMessage = 'Ingrese al menos 3 caracteres para buscar.';
      isSearchingCustomer = false;
      notifyListeners();
      return;
    }
    isSearchingCustomer = true;
    customerSearchMessage = null;
    notifyListeners();
    try {
      final response = await datasource.searchCustomers(cleanQuery);
      if (_disposed || generation != _generation) return;
      customerResults = response.customers;
      customerSearchMessage = customerResults.isEmpty
          ? 'No se encontraron clientes.'
          : null;
    } catch (e) {
      if (_disposed || generation != _generation) return;
      customerResults = [];
      customerSearchMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      if (!_disposed && generation == _generation) {
        isSearchingCustomer = false;
        notifyListeners();
      }
    }
  }

  void selectCustomer(SteamTrapCustomer customer) {
    _debounce?.cancel();
    _generation++;
    selectedCustomer = customer;
    customerSearchController.text = customer.shortDisplayName;
    customerResults = [];
    customerSearchMessage = null;
    isSearchingCustomer = false;
    onCustomerChanged?.call();
    notifyListeners();
  }

  void clearSelectedCustomer() {
    _debounce?.cancel();
    _generation++;
    selectedCustomer = null;
    customerSearchController.clear();
    customerResults = [];
    customerSearchMessage = null;
    isSearchingCustomer = false;
    onCustomerChanged?.call();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    _debounce?.cancel();
    customerSearchController.dispose();
    super.dispose();
  }
}
