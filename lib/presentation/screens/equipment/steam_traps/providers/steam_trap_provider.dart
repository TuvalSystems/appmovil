import 'package:tuvalapp/presentation/providers/point_sales_provider.dart';
import 'package:tuvalapp/infrastructure/datasources/customers_datasource.dart';
import 'package:flutter/widgets.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/helpers/decimal_input.dart';
import 'package:tuvalapp/presentation/shared/controllers/customer_search_controller.dart';
import 'package:tuvalapp/infrastructure/datasources/steam_trap_datasource.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_customer.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_sizing_request.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/constants/steam_traps_catalogs.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/helpers/steam_trap_calculator.dart';
import 'package:tuvalapp/presentation/shared/widgets/app_toast.dart';

class SteamTrapProvider extends ChangeNotifier {
  final SteamTrapDatasource steamTrapDataSource;
  final CustomerSearchController customerSearch;
  final PointSalesProvider? pointSalesProvider;
  int? _pointSaleId;
  int _revision = 0;
  bool _disposed = false;
  bool get isBusy => isSending || isCreateQuote;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  bool _current(int revision) => !_disposed && revision == _revision;
  void _pointSaleChanged() {
    final id = pointSalesProvider?.selectedPvId;
    if (_pointSaleId == id) return;
    _pointSaleId = id;
    clearGeneratedResult();
  }

  SteamTrapProvider({
    SteamTrapDatasource? steamTrapDataSource,
    CustomersDatasource? customersDatasource,
    this.pointSalesProvider,
  }) : steamTrapDataSource = steamTrapDataSource ?? SteamTrapDatasource(),
       customerSearch = CustomerSearchController(
         datasource: customersDatasource,
       ) {
    customerSearch.addListener(_notify);
    _pointSaleId = pointSalesProvider?.selectedPvId;
    pointSalesProvider?.addListener(_pointSaleChanged);
    customerSearch.onCustomerChanged = clearGeneratedResult;
  }

  SteamTrapCustomer? get selectedCustomer => customerSearch.selectedCustomer;

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
    _revision++;
    sendMessageType = null;
    sendMessage = null;
    generatedPdfUrl = null;
    _notify();
  }

  double toDouble(String value, {bool optional = false}) {
    if (optional && value.trim().isEmpty) return 0;
    return DecimalInput.parse(value) ?? double.nan;
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

    if (toDouble(knownLoadController.text, optional: true) > 0) {
      return 'Carga conocida ingresada';
    }

    return 'Arrastre estimado por BHP';
  }

  String? get validationMessage {
    final fields = <String, String>{
      'presión de trabajo': pressureController.text,
      'presión de retorno': returnPressureController.text,
      if (isHeatingProcess) ...{
        'volumen': volumeController.text,
        'temperatura inicial': tempIniController.text,
        'temperatura final': tempFinController.text,
        'tiempo': tiempoController.text,
      },
      if (isDrainProcess) ...{
        if (knownLoadController.text.trim().isNotEmpty)
          'carga conocida': knownLoadController.text,
        if (boilerBhpController.text.trim().isNotEmpty)
          'capacidad de caldera': boilerBhpController.text,
      },
    };
    for (final field in fields.entries) {
      if (DecimalInput.parse(field.value) == null) {
        return 'Ingrese un número válido en ${field.key}.';
      }
    }
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
      final knownLoad = toDouble(knownLoadController.text, optional: true);
      final bhp = toDouble(boilerBhpController.text, optional: true);

      if (knownLoad <= 0 && bhp <= 0) {
        return 'Ingrese la carga conocida del punto o la capacidad del caldero en BHP.';
      }
    }

    if (![
      pressurePsig,
      returnPressurePsig,
      pressureDifferentialPsig,
      cargaEstimada,
      cargaConFs,
      if (isHeatingProcess) ...[deltaT, massKg, calorRequeridoKj, hfg],
    ].every((value) => value.isFinite)) {
      return 'Los valores ingresados exceden el rango de cálculo. Redúzcalos.';
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

    if (toDouble(knownLoadController.text, optional: true) > 0) {
      return toDouble(knownLoadController.text, optional: true);
    }

    return SteamTrapCalculator.condensateFromBhp(
      bhp: toDouble(boilerBhpController.text, optional: true),
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
    if (_disposed || isBusy) return;
    final revision = _revision;
    if (selectedCustomer == null) {
      sendMessage = 'Seleccione un cliente antes de generar el PDF.';
      sendMessageType = AppToastType.warning;
      _notify();
      return;
    }

    final validation = validationMessage;

    if (validation != null) {
      sendMessage = validation;
      sendMessageType = AppToastType.warning;
      _notify();
      return;
    }

    generatedPdfUrl = null;
    isSending = true;
    sendMessage = null;
    sendMessageType = null;
    _notify();

    try {
      final request = buildSizingRequest(
        pvId: pvId,
        pvCode: pvCode,
        pvDescription: pvDescription,
      );

      final response = await steamTrapDataSource.generateSizingPdf(request);
      if (!_current(revision)) return;

      generatedPdfUrl = response.pdfUrl;
      sendMessage = response.message;
      sendMessageType = AppToastType.success;
    } catch (e) {
      if (!_current(revision)) return;
      sendMessageType = AppToastType.error;
      sendMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isSending = false;
      _notify();
    }
  }

  Future<void> createDraftQuote({
    required int pvId,
    required String pvCode,
    required String pvDescription,
  }) async {
    if (_disposed || isBusy) return;
    final revision = _revision;
    if (selectedCustomer == null) {
      sendMessage = 'Seleccione un cliente antes de crear la cotización.';
      sendMessageType = AppToastType.warning;
      _notify();
      return;
    }

    final validation = validationMessage;

    if (validation != null) {
      sendMessage = validation;
      sendMessageType = AppToastType.warning;
      _notify();
      return;
    }

    isCreateQuote = true;
    sendMessage = null;
    sendMessageType = null;
    _notify();

    try {
      final request = buildSizingRequest(
        pvId: pvId,
        pvCode: pvCode,
        pvDescription: pvDescription,
      );

      final response = await steamTrapDataSource.createDraftQuote(request);
      if (!_current(revision)) return;

      sendMessage = response.message;
      sendMessageType = AppToastType.success;
    } catch (e) {
      if (!_current(revision)) return;
      sendMessageType = AppToastType.error;
      sendMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      isCreateQuote = false;
      _notify();
    }
  }

  SteamTrapSizingRequest buildSizingRequest({
    required int pvId,
    required String pvCode,
    required String pvDescription,
  }) {
    final validation = validationMessage;
    if (validation != null) throw StateError(validation);
    final isHeating = isHeatingProcess;
    final knownLoad = toDouble(knownLoadController.text, optional: true);
    final boilerBhp = toDouble(boilerBhpController.text, optional: true);

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
    _disposed = true;
    _revision++;
    pointSalesProvider?.removeListener(_pointSaleChanged);
    customerSearch.removeListener(_notify);
    customerSearch.dispose();
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
