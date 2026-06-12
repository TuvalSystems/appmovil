import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tuvalapp/infrastructure/datasources/customers_datasource.dart';
import 'package:tuvalapp/infrastructure/datasources/steam_trap_datasource.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_customer.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_sizing_request.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/constants/steam_traps_catalogs.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/helpers/steam_trap_calculator.dart';
import 'package:tuvalapp/presentation/shared/widgets/app_toast.dart';

class SteamTrapProvider extends ChangeNotifier {
  final SteamTrapDatasource steamTrapDataSource = SteamTrapDatasource();
  final CustomersDatasource customersDatasource = CustomersDatasource();

  Timer? _customerSearchDebounce;

  bool isSending = false;
  bool isCreateQuote = false;

  String? sendMessage;
  AppToastType? sendMessageType;
  String? generatedPdfUrl;

  String selectedProcess = 'Marmita';
  String selectedFluid = 'Agua';
  String selectedUnd = 'psig';

  final returnPressureController = TextEditingController(text: '0');
  final pressureController = TextEditingController(text: '5');
  final volumeController = TextEditingController(text: '0.10');
  final tempIniController = TextEditingController(text: '20');
  final tempFinController = TextEditingController(text: '90');
  final tiempoController = TextEditingController(text: '30');
  final knownLoadController = TextEditingController(text: '');
  final boilerBhpController = TextEditingController(text: '100');
  final customerSearchController = TextEditingController();

  bool isSearchingCustomer = false;
  String? customerSearchMessage;

  SteamTrapCustomer? selectedCustomer;
  List<SteamTrapCustomer> customerResults = [];

  void setProcess(String value) {
    selectedProcess = value;
    clearGeneratedResult();
  }

  void setFluid(String value) {
    selectedFluid = value;
    clearGeneratedResult();
  }

  void setPressureUnit(String value) {
    selectedUnd = value;
    clearGeneratedResult();
  }

  void clearGeneratedResult() {
    sendMessage = null;
    generatedPdfUrl = null;
    notifyListeners();
  }

  void onCustomerSearchChanged(String value) {
    _customerSearchDebounce?.cancel();

    final query = value.trim();

    selectedCustomer = null;
    customerResults = [];
    customerSearchMessage = null;
    sendMessage = null;
    generatedPdfUrl = null;

    if (query.isEmpty) {
      isSearchingCustomer = false;
      notifyListeners();
      return;
    }

    if (query.length < 3) {
      isSearchingCustomer = false;
      customerSearchMessage = 'Ingrese al menos 3 caracteres para buscar.';
      notifyListeners();
      return;
    }

    isSearchingCustomer = true;
    notifyListeners();

    _customerSearchDebounce = Timer(const Duration(milliseconds: 450), () {
      searchCustomers(query);
    });
  }

  Future<void> searchCustomers(String query) async {
    final cleanQuery = query.trim();

    if (cleanQuery.length < 3) {
      customerResults = [];
      customerSearchMessage = 'Ingrese al menos 3 caracteres para buscar.';
      isSearchingCustomer = false;
      notifyListeners();
      return;
    }

    try {
      final response = await customersDatasource.searchCustomers(cleanQuery);
      final data = response['data'];

      if (data is List) {
        final results = data
            .whereType<Map>()
            .map((item) {
              return SteamTrapCustomer.fromJson(
                Map<String, dynamic>.from(item),
              );
            })
            .where((customer) {
              return customer.id > 0 &&
                  customer.ruc.isNotEmpty &&
                  customer.razonSocial.isNotEmpty;
            })
            .toList();

        customerResults = results;
      } else {
        customerResults = [];
      }

      customerSearchMessage = customerResults.isEmpty
          ? 'No se encontraron clientes.'
          : null;
    } catch (e) {
      customerResults = [];
      customerSearchMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isSearchingCustomer = false;
      notifyListeners();
    }
  }

  void selectCustomer(SteamTrapCustomer customer) {
    selectedCustomer = customer;
    customerSearchController.text = customer.shortDisplayName;
    customerResults = [];
    customerSearchMessage = null;

    sendMessage = null;
    generatedPdfUrl = null;

    notifyListeners();
  }

  void clearSelectedCustomer() {
    _customerSearchDebounce?.cancel();

    selectedCustomer = null;
    customerResults = [];
    customerSearchMessage = null;
    customerSearchController.clear();

    sendMessage = null;
    generatedPdfUrl = null;

    isSearchingCustomer = false;

    notifyListeners();
  }

  double toDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0.0;
  }

  double get pressurePsig {
    return SteamTrapCalculator.pressureToPsig(
      toDouble(pressureController.text),
      selectedUnd,
    );
  }

  double get returnPressurePsig {
    return SteamTrapCalculator.pressureToPsig(
      toDouble(returnPressureController.text),
      selectedUnd,
    );
  }

  double get pressureDifferentialPsig {
    return pressurePsig - returnPressurePsig;
  }

  bool get isHeatingProcess {
    return SteamTrapsCatalogs.heatingProcesses.contains(selectedProcess);
  }

  bool get isDrainProcess {
    return SteamTrapsCatalogs.drainProcesses.contains(selectedProcess);
  }

  double get cp {
    return SteamTrapsCatalogs.fluidProperties[selectedFluid]?['cp'] ?? 4.19;
  }

  double get rho {
    return SteamTrapsCatalogs.fluidProperties[selectedFluid]?['rho'] ?? 1000;
  }

  double get deltaT {
    return toDouble(tempFinController.text) - toDouble(tempIniController.text);
  }

  double get massKg {
    return rho * toDouble(volumeController.text);
  }

  double get hfg {
    return SteamTrapCalculator.hfgFromPsig(pressurePsig);
  }

  double get calorRequeridoKj {
    if (massKg <= 0) return 0;
    if (cp <= 0) return 0;
    if (deltaT <= 0) return 0;

    return massKg * cp * deltaT;
  }

  String get calculationMethod {
    if (isHeatingProcess) {
      return 'Energía / calentamiento indirecto';
    }

    if (toDouble(knownLoadController.text) > 0) {
      return 'Carga conocida ingresada';
    }

    return 'Arrastre estimado por BHP';
  }

  String? get validationMessage {
    if (pressurePsig <= 0) {
      return 'Ingrese una presión de trabajo válida.';
    }

    if (returnPressurePsig < 0) {
      return 'La presión de retorno no puede ser negativa.';
    }

    if (returnPressurePsig >= pressurePsig) {
      return 'La presión de retorno debe ser menor que la presión de trabajo.';
    }

    if (isHeatingProcess && (pressurePsig < 5 || pressurePsig > 250)) {
      return 'Para calentamiento, la tabla hfg disponible cubre de 5 a 250 PSIG.';
    }

    if (!isHeatingProcess && pressurePsig > 600) {
      return 'La presión supera 600 PSIG. Requiere revisión técnica.';
    }

    if (isHeatingProcess) {
      if (toDouble(volumeController.text) <= 0) {
        return 'Ingrese un volumen mayor a 0.';
      }

      if (toDouble(tiempoController.text) <= 0) {
        return 'Ingrese un tiempo mayor a 0.';
      }

      if (deltaT <= 0) {
        return 'La temperatura final debe ser mayor a la inicial.';
      }
    }

    if (isDrainProcess) {
      final knownLoad = toDouble(knownLoadController.text);
      final bhp = toDouble(boilerBhpController.text);

      if (knownLoad <= 0 && bhp <= 0) {
        return 'Ingrese la carga conocida del punto o la capacidad del caldero en BHP.';
      }
    }

    return null;
  }

  double get cargaEstimada {
    if (isHeatingProcess) {
      return SteamTrapCalculator.condensateFromHeating(
        volumeM3: toDouble(volumeController.text),
        densityKgM3: rho,
        cpKjKgC: cp,
        tempInicialC: toDouble(tempIniController.text),
        tempFinalC: toDouble(tempFinController.text),
        timeMin: toDouble(tiempoController.text),
        hfgKjKg: hfg,
      );
    }

    if (toDouble(knownLoadController.text) > 0) {
      return toDouble(knownLoadController.text);
    }

    return SteamTrapCalculator.condensateFromBhp(
      bhp: toDouble(boilerBhpController.text),
    );
  }

  double get cargaConFs {
    return cargaEstimada * 1.5;
  }

  String get recommendedTrap {
    if (isHeatingProcess) {
      return 'Flotador';
    }

    if (selectedProcess == 'Traceo') {
      return 'Termodinámica';
    }

    if (isDrainProcess && pressurePsig > 250 && pressurePsig <= 600) {
      return 'Termodinámica';
    }

    if (isDrainProcess && pressurePsig <= 250) {
      return 'Balde invertido';
    }

    return 'Revisar condición técnica';
  }

  Future<void> generateSizingPdf({
    required int pvId,
    required String pvCode,
    required String pvDescription,
  }) async {
    if (selectedCustomer == null) {
      sendMessage = 'Seleccione un cliente antes de generar el PDF.';
      sendMessageType = AppToastType.warning;
      notifyListeners();
      return;
    }

    final validation = validationMessage;

    if (validation != null) {
      sendMessage = validation;
      sendMessageType = AppToastType.warning;
      notifyListeners();
      return;
    }

    isSending = true;
    sendMessage = null;
    sendMessageType = null;
    notifyListeners();

    try {
      final request = buildSizingRequest(
        pvId: pvId,
        pvCode: pvCode,
        pvDescription: pvDescription,
      );

      final response = await steamTrapDataSource.generateSizingPdf(request);

      final data = response['data'];
      final pdfUrl = data is Map ? data['pdfUrl']?.toString() : null;

      generatedPdfUrl = pdfUrl;
      sendMessage =
          response['message']?.toString() ?? 'PDF generado correctamente.';
      sendMessageType = AppToastType.success;
    } catch (e) {
      sendMessage = e.toString().replaceAll('Exception: ', '');
      sendMessageType = AppToastType.error;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  Future<void> createDraftQuote({
    required int pvId,
    required String pvCode,
    required String pvDescription,
  }) async {
    if (selectedCustomer == null) {
      sendMessage = 'Seleccione un cliente antes de crear la cotización.';
      sendMessageType = AppToastType.warning;
      notifyListeners();
      return;
    }

    final validation = validationMessage;

    if (validation != null) {
      sendMessage = validation;
      sendMessageType = AppToastType.warning;
      notifyListeners();
      return;
    }

    isCreateQuote = true;
    sendMessage = null;
    sendMessageType = null;
    notifyListeners();

    try {
      final request = buildSizingRequest(
        pvId: pvId,
        pvCode: pvCode,
        pvDescription: pvDescription,
      );

      final response = await steamTrapDataSource.createDraftQuote(request);

      sendMessage =
          response['message']?.toString() ??
          'Cotización borrador creada correctamente.';
      sendMessageType = AppToastType.success;
    } catch (e) {
      sendMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isCreateQuote = false;
      notifyListeners();
    }
  }

  SteamTrapSizingRequest buildSizingRequest({
    required int pvId,
    required String pvCode,
    required String pvDescription,
  }) {
    final isHeating = isHeatingProcess;
    final knownLoad = toDouble(knownLoadController.text);
    final boilerBhp = toDouble(boilerBhpController.text);

    return SteamTrapSizingRequest(
      customerId: selectedCustomer?.id,
      customerRuc: selectedCustomer?.ruc,
      pvId: pvId,
      pvCode: pvCode,
      pvDescription: pvDescription,
      process: selectedProcess,
      trapType: recommendedTrap,
      calculationMethod: calculationMethod,
      workingPressurePsig: pressurePsig,
      returnPressurePsig: returnPressurePsig,
      pressureDifferentialPsig: pressureDifferentialPsig,
      fluid: isHeating ? selectedFluid : null,
      volumeM3: isHeating ? toDouble(volumeController.text) : null,
      densityKgM3: isHeating ? rho : null,
      cpKjKgC: isHeating ? cp : null,
      initialTemperatureC: isHeating ? toDouble(tempIniController.text) : null,
      finalTemperatureC: isHeating ? toDouble(tempFinController.text) : null,
      heatingTimeMin: isHeating ? toDouble(tiempoController.text) : null,
      requiredHeatKj: isHeating ? calorRequeridoKj : null,
      hfgKjKg: isHeating ? hfg : null,
      knownLoadKgH: !isHeating && knownLoad > 0 ? knownLoad : null,
      boilerBhp: !isHeating && knownLoad <= 0 && boilerBhp > 0
          ? boilerBhp
          : null,
      estimatedLoadKg: cargaEstimada,
      safetyFactor: 1.5,
      loadWithSafetyFactorKg: cargaConFs,
    );
  }

  String fmt(double value, [int decimals = 2]) {
    if (value.isNaN || value.isInfinite) return '-';
    return value.toStringAsFixed(decimals);
  }

  @override
  void dispose() {
    _customerSearchDebounce?.cancel();

    customerSearchController.dispose();
    pressureController.dispose();
    volumeController.dispose();
    tempIniController.dispose();
    tempFinController.dispose();
    tiempoController.dispose();
    knownLoadController.dispose();
    boilerBhpController.dispose();
    returnPressureController.dispose();

    super.dispose();
  }
}
