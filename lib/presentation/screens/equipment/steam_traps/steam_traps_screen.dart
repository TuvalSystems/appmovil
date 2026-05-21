import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/side_menu.dart';

class SteamTrapsScreen extends StatefulWidget {
  const SteamTrapsScreen({super.key});

  @override
  State<SteamTrapsScreen> createState() => _SteamTrapsScreenState();
}

class _SteamTrapsScreenState extends State<SteamTrapsScreen> {
  Timer? _resultDebounce;
  void _scheduleResultRefresh() {
    _resultDebounce?.cancel();

    _resultDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() {});
    });
  }

  String selectedProcess = 'Marmita';
  String selectedUnd = 'psig';

  final TextEditingController pressureController = TextEditingController(
    text: '5',
  );

  final TextEditingController volumeController = TextEditingController(
    text: '0.10',
  );

  final TextEditingController tempIniController = TextEditingController(
    text: '20',
  );

  final TextEditingController tempFinController = TextEditingController(
    text: '90',
  );

  final TextEditingController tiempoController = TextEditingController(
    text: '30',
  );

  final TextEditingController knownLoadController = TextEditingController(
    text: '',
  );

  final TextEditingController boilerBhpController = TextEditingController(
    text: '100',
  );

  final List<String> listProcess = [
    'Marmita',
    'Intercambiador (placas/tubos)',
    'Rotatubos',
    'Rotadiscos',
    'Peletizadora',
    'Extrusora',
    'Autoclave',
    'Bota de condensado',
    'Separador de humedad',
    'Distribuidor',
    'Final de línea',
    'Traceo',
  ];

  static const List<Map<String, double>> _steamTablePsig = [
    {'psig': 5, 'hfg': 2234.1},
    {'psig': 10, 'hfg': 2215.5},
    {'psig': 15, 'hfg': 2199.4},
    {'psig': 20, 'hfg': 2185.3},
    {'psig': 25, 'hfg': 2172.5},
    {'psig': 30, 'hfg': 2160.3},
    {'psig': 35, 'hfg': 2149.1},
    {'psig': 40, 'hfg': 2138.5},
    {'psig': 45, 'hfg': 2128.9},
    {'psig': 50, 'hfg': 2121.1},
    {'psig': 55, 'hfg': 2112.5},
    {'psig': 60, 'hfg': 2104.3},
    {'psig': 65, 'hfg': 2096.7},
    {'psig': 70, 'hfg': 2089.7},
    {'psig': 75, 'hfg': 2081.8},
    {'psig': 80, 'hfg': 2074.4},
    {'psig': 85, 'hfg': 2067.5},
    {'psig': 90, 'hfg': 2061.1},
    {'psig': 95, 'hfg': 2055.0},
    {'psig': 100, 'hfg': 2049.0},
    {'psig': 105, 'hfg': 2042.9},
    {'psig': 110, 'hfg': 2037.3},
    {'psig': 115, 'hfg': 2031.3},
    {'psig': 120, 'hfg': 2025.7},
    {'psig': 125, 'hfg': 2020.1},
    {'psig': 130, 'hfg': 2014.8},
    {'psig': 135, 'hfg': 2009.4},
    {'psig': 140, 'hfg': 2004.3},
    {'psig': 145, 'hfg': 1999.4},
    {'psig': 150, 'hfg': 1994.3},
    {'psig': 155, 'hfg': 1989.4},
    {'psig': 160, 'hfg': 1984.8},
    {'psig': 165, 'hfg': 1980.4},
    {'psig': 170, 'hfg': 1975.7},
    {'psig': 175, 'hfg': 1971.5},
    {'psig': 180, 'hfg': 1967.3},
    {'psig': 185, 'hfg': 1962.9},
    {'psig': 190, 'hfg': 1957.7},
    {'psig': 195, 'hfg': 1953.3},
    {'psig': 200, 'hfg': 1948.7},
    {'psig': 205, 'hfg': 1944.5},
    {'psig': 210, 'hfg': 1940.3},
    {'psig': 215, 'hfg': 1936.2},
    {'psig': 220, 'hfg': 1932.2},
    {'psig': 225, 'hfg': 1928.0},
    {'psig': 230, 'hfg': 1924.1},
    {'psig': 235, 'hfg': 1920.1},
    {'psig': 240, 'hfg': 1916.4},
    {'psig': 245, 'hfg': 1912.4},
    {'psig': 250, 'hfg': 1908.7},
  ];

  static const Map<String, Map<String, double>> _fluidProperties = {
    'Agua': {'cp': 4.19, 'rho': 1000},
    'Agua salada': {'cp': 4.00, 'rho': 1028},
    'Aceite': {'cp': 2.30, 'rho': 900},
    'Bunker': {'cp': 2.09, 'rho': 950},
  };

  final List<String> listFluids = ['Agua', 'Agua salada', 'Aceite', 'Bunker'];

  String selectedFluid = 'Agua';

  double _toDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
  }

  double get _pressurePsig {
    return _pressureToPsig(_toDouble(pressureController.text), selectedUnd);
  }

  double get _hfg {
    return _hfgFromPsig(_pressurePsig);
  }

  double get _cp {
    return _fluidProperties[selectedFluid]?['cp'] ?? 4.19;
  }

  double get _rho {
    return _fluidProperties[selectedFluid]?['rho'] ?? 1000;
  }

  double get _deltaT {
    return _toDouble(tempFinController.text) -
        _toDouble(tempIniController.text);
  }

  double get _massKg {
    return _rho * _toDouble(volumeController.text);
  }

  bool get _isHeatingProcess {
    return [
      'Marmita',
      'Intercambiador (placas/tubos)',
      'Rotatubos',
      'Rotadiscos',
      'Peletizadora',
      'Extrusora',
      'Autoclave',
    ].contains(selectedProcess);
  }

  bool get _isDrainProcess {
    return [
      'Bota de condensado',
      'Separador de humedad',
      'Distribuidor',
      'Final de línea',
      'Traceo',
    ].contains(selectedProcess);
  }

  double _pressureToPsig(double pressure, String unit) {
    switch (unit.toLowerCase()) {
      case 'psig':
        return pressure;
      case 'barg':
        return (pressure + 1.01325) / 0.0689476 - 14.6959;
      case 'kpag':
        return (pressure / 100 + 1.01325) / 0.0689476 - 14.6959;
      case 'psia':
        return pressure - 14.6959;
      case 'bara':
        return pressure / 0.0689476 - 14.6959;
      case 'kpaa':
        return (pressure / 100) / 0.0689476 - 14.6959;
      default:
        return pressure;
    }
  }

  double _hfgFromPsig(double psig) {
    if (psig <= _steamTablePsig.first['psig']!) {
      return _steamTablePsig.first['hfg']!;
    }

    if (psig >= _steamTablePsig.last['psig']!) {
      return _steamTablePsig.last['hfg']!;
    }

    for (int i = 0; i < _steamTablePsig.length - 1; i++) {
      final a = _steamTablePsig[i];
      final b = _steamTablePsig[i + 1];

      final x1 = a['psig']!;
      final x2 = b['psig']!;

      if (psig >= x1 && psig <= x2) {
        final y1 = a['hfg']!;
        final y2 = b['hfg']!;
        final factor = (psig - x1) / (x2 - x1);

        return y1 + ((y2 - y1) * factor);
      }
    }

    return 0;
  }

  double get _calorRequeridoKj {
    if (_massKg <= 0) return 0;
    if (_cp <= 0) return 0;
    if (_deltaT <= 0) return 0;

    return _massKg * _cp * _deltaT;
  }

  String get _calculationMethod {
    if (_isHeatingProcess) {
      return 'Energía / calentamiento indirecto';
    }

    if (_toDouble(knownLoadController.text) > 0) {
      return 'Carga conocida ingresada';
    }

    return 'Arrastre estimado por BHP';
  }

  String? get _validationMessage {
    if (_pressurePsig <= 0) {
      return 'Ingrese una presión de trabajo válida.';
    }
    if (_isHeatingProcess && (_pressurePsig < 5 || _pressurePsig > 250)) {
      return 'Para calentamiento, la tabla hfg disponible cubre de 5 a 250 PSIG.';
    }

    if (!_isHeatingProcess && _pressurePsig > 600) {
      return 'La presión supera 600 PSIG. Requiere revisión técnica.';
    }

    if (_isHeatingProcess) {
      if (_toDouble(volumeController.text) <= 0) {
        return 'Ingrese un volumen mayor a 0.';
      }

      if (_toDouble(tiempoController.text) <= 0) {
        return 'Ingrese un tiempo mayor a 0.';
      }

      if (_deltaT <= 0) {
        return 'La temperatura final debe ser mayor a la inicial.';
      }
    }

    if (_isDrainProcess) {
      final knownLoad = _toDouble(knownLoadController.text);
      final bhp = _toDouble(boilerBhpController.text);

      if (knownLoad <= 0 && bhp <= 0) {
        return 'Ingrese la carga conocida del punto o la capacidad del caldero en BHP.';
      }
    }

    return null;
  }

  double get _cargaEstimada {
    if (_isHeatingProcess) {
      return _condensateFromHeating(
        volumeM3: _toDouble(volumeController.text),
        densityKgM3: _rho,
        cpKjKgC: _cp,
        tempInicialC: _toDouble(tempIniController.text),
        tempFinalC: _toDouble(tempFinController.text),
        timeMin: _toDouble(tiempoController.text),
        hfgKjKg: _hfg,
      );
    }

    if (_toDouble(knownLoadController.text) > 0) {
      return _toDouble(knownLoadController.text);
    }

    return _condensateFromBhp(bhp: _toDouble(boilerBhpController.text));
  }

  double get _cargaConFs {
    return _cargaEstimada * 1.5;
  }

  double _condensateFromHeating({
    required double volumeM3,
    required double densityKgM3,
    required double cpKjKgC,
    required double tempInicialC,
    required double tempFinalC,
    required double timeMin,
    required double hfgKjKg,
  }) {
    if (volumeM3 <= 0) return 0;
    if (densityKgM3 <= 0) return 0;
    if (cpKjKgC <= 0) return 0;
    if (timeMin <= 0) return 0;
    if (hfgKjKg <= 0) return 0;
    if (tempFinalC <= tempInicialC) return 0;

    final deltaT = tempFinalC - tempInicialC;

    return (60 * densityKgM3 * volumeM3 * cpKjKgC * deltaT) /
        (hfgKjKg * timeMin);
  }

  double _condensateFromBhp({required double bhp}) {
    if (bhp <= 0) return 0;

    return 0.15 * bhp * 15.65;
  }

  String _recommendedTrap(String process) {
    if (_isHeatingProcess) {
      return 'Flotador';
    }

    if (process == 'Traceo') {
      return 'Termodinámica';
    }

    if (_isDrainProcess && _pressurePsig > 250 && _pressurePsig <= 600) {
      return 'Termodinámica';
    }

    if (_isDrainProcess && _pressurePsig <= 250) {
      return 'Balde invertido';
    }

    return 'Revisar condición técnica';
  }

  String _fmt(double value, [int decimals = 2]) {
    if (value.isNaN || value.isInfinite) return '-';
    return value.toStringAsFixed(decimals);
  }

  @override
  void dispose() {
    _resultDebounce?.cancel();

    pressureController.dispose();
    volumeController.dispose();
    tempIniController.dispose();
    tempFinController.dispose();
    tiempoController.dispose();
    knownLoadController.dispose();
    boilerBhpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      drawer: const SideMenu(),

      appBar: AppBar(
        title: const Text(
          'Trampas de Vapor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.brand,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      //nuevo body
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: ScrollConfiguration(
          behavior: const _NoStretchScrollBehavior(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: _mainCard(),
          ),
        ),
      ),
    );
  }

  Widget _mainCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffdce6f2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trampas de vapor (selector rápido)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xff07142b),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Calcula una carga estimada y sugiere tipo de trampa según el proceso.',
            style: TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          const Text(
            'Proceso / aplicación',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xff344563),
            ),
          ),
          const SizedBox(height: 8),
          _appDropdown(
            value: selectedProcess,
            items: listProcess,
            onChanged: (value) {
              setState(() {
                selectedProcess = value!;
              });
              _scheduleResultRefresh();
            },
          ),
          const SizedBox(height: 14),
          _pressureCard(),
          const SizedBox(height: 14),
          _calculationCard(),
          const SizedBox(height: 14),
          _recommendationCard(),
        ],
      ),
    );
  }

  Widget _pressureCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Datos de presión',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff07142b),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffeef3f9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Se usa hfg por tabla PSIG',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff07142b),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 430;

              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: _appInput(
                        label: 'Presión de trabajo',
                        controller: pressureController,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(width: 220, child: _unitBadge()),
                  ],
                );
              }

              return Column(
                children: [
                  _appInput(
                    label: 'Presión de trabajo',
                    controller: pressureController,
                  ),
                  const SizedBox(height: 12),
                  _unitBadge(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _calculationCard() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 430;

              if (isWide) {
                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Cálculo de carga',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff07142b),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffeef3f9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _isHeatingProcess
                            ? 'Ruta: calentamiento indirecto'
                            : 'Ruta: drenaje / arrastre',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff07142b),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cálculo de carga',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff07142b),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffeef3f9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _isHeatingProcess
                          ? 'Ruta: calentamiento indirecto'
                          : 'Ruta: drenaje / arrastre',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff07142b),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _isHeatingProcess ? _heatingFields() : _dragFields(),
          ),
        ],
      ),
    );
  }

  Widget _heatingFields() {
    return Column(
      key: const ValueKey('calentamiento'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _appDropdownWithLabel(
          label: 'Fluido a calentar',
          value: selectedFluid,
          items: listFluids,
          onChanged: (value) {
            setState(() {
              selectedFluid = value!;
            });
            _scheduleResultRefresh();
          },
        ),

        const SizedBox(height: 14),

        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final int columns = width >= 520 ? 3 : 2;
            final double spacing = 10;
            final double itemWidth =
                (width - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: 14,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _appInput(
                    label: 'Volumen (m³) *',
                    controller: volumeController,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _appInput(
                    label: 'Temp. inicial (°C)',
                    controller: tempIniController,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _appInput(
                    label: 'Temp. final (°C)',
                    controller: tempFinController,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _appInput(
                    label: 'Tiempo (min)',
                    controller: tiempoController,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Cp: ${_fmt(_cp, 2)} kJ/kg·°C · Densidad: ${_fmt(_rho, 0)} kg/m³ · Masa calculada: ${_fmt(_massKg, 2)} kg',
          style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.35),
        ),
      ],
    );
  }

  Widget _dragFields() {
    return Column(
      key: const ValueKey('arrastre'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Si conoce la carga de condensado del punto, ingrésela directamente. Si no, ingrese la capacidad del caldero en BHP.',
          style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.35),
        ),
        const SizedBox(height: 16),
        _appInput(
          label: 'Carga conocida del punto (kg/h)',
          controller: knownLoadController,
        ),
        const SizedBox(height: 14),
        _appInput(
          label: 'Capacidad de caldera (BHP)',
          controller: boilerBhpController,
        ),
        const SizedBox(height: 10),
        Text(
          'Si no se ingresa carga conocida, se estima: 0.15 × BHP × 15.65 = 2.35 × BHP.',
          style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.35),
        ),
      ],
    );
  }

  Widget _recommendationCard() {
    final rec = _recommendedTrap(selectedProcess);
    final validationMessage = _validationMessage;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff07101f),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recomendación',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),

          Text(
            rec,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Presión: ${_fmt(_pressurePsig, 2)} PSIG',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),

          const SizedBox(height: 8),

          if (_isHeatingProcess) ...[
            Text(
              'hfg: ${_fmt(_hfg, 1)} kJ/kg',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'Método: $_calculationMethod',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),

          if (_isHeatingProcess) ...[
            const SizedBox(height: 8),
            Text(
              'Q requerido: ${_fmt(_calorRequeridoKj, 2)} kJ',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),

          if (validationMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                validationMessage,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _resultBox(
                    title: 'Carga estimada',
                    value: '${_fmt(_cargaEstimada, 2)} kg/h',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _resultBox(
                    title: 'Referencia con FS=1.5',
                    value: '${_fmt(_cargaConFs, 2)} kg/h',
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          Text(
            _isHeatingProcess
                ? 'Cálculo por energía: 60 × ρ × V × Cp × ΔT / (hfg × t min).'
                : 'Cálculo por drenaje: carga conocida o 0.15 × BHP × 15.65.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfffbfdff),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffdce6f2)),
      ),
      child: child,
    );
  }

  Widget _resultBox({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff273040),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _appDropdownWithLabel({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        _appDropdown(value: value, items: items, onChanged: onChanged),
      ],
    );
  }

  Widget _unitBadge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Unidad'),
        const SizedBox(height: 8),
        Container(
          height: 46,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xffdce6f2)),
          ),
          child: const Text(
            'PSIG',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xff07142b),
            ),
          ),
        ),
      ],
    );
  }

  Widget _appDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffdce6f2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xff07142b),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xff07142b)),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _appInput({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
  }) {
    final bool isTextField = keyboardType == TextInputType.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        const SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: TextInputAction.done,
            onChanged: (_) => _scheduleResultRefresh(),
            onSubmitted: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              hintText: isTextField ? 'Escriba aquí' : '0.00',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xffdce6f2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xffdce6f2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.brand, width: 1.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Color(0xff344563),
      ),
    );
  }
}

class _NoStretchScrollBehavior extends MaterialScrollBehavior {
  const _NoStretchScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
