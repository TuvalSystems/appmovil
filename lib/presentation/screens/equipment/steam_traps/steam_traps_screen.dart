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
  static const double _xQuality = 0.9;
  Timer? _resultDebounce;
  final ValueNotifier<int> _resultTick = ValueNotifier<int>(0);

  void _scheduleResultRefresh() {
    _resultDebounce?.cancel();

    _resultDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      _resultTick.value++;
    });
  }

  String selectedProcess = 'Marmita';
  String selectedUnd = 'kpag';

  // Valores internos iguales a la lógica JS.
  String selectedType = 'CALENTAMIENTO';
  String flowMode = 'LINEA';

  final TextEditingController pressureController = TextEditingController(
    text: '1',
  );

  final TextEditingController materialController = TextEditingController(
    text: 'Agua',
  );

  final TextEditingController masaController = TextEditingController(
    text: '100',
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

  final TextEditingController cpController = TextEditingController(
    text: '4.186',
  );

  final TextEditingController porcentajeArrastreController =
      TextEditingController(text: '12');

  final TextEditingController flujoLineaController = TextEditingController(
    text: '1000',
  );

  final TextEditingController boilerCapController = TextEditingController(
    text: '1000',
  );

  final List<String> listProcess = [
    'Marmita',
    'Intercambiador (placas/tubos)',
    'Rotatubos',
    'Rotadiscos',
    'Peletizadora',
    'Extrusora',
    'Bota de condensado',
    'Separador de humedad',
    'Final de línea',
    'Vapor sobrecalentado >200 PSI',
  ];

  final List<String> listUnd = ['psig', 'barg', 'kpag', 'psia', 'bara', 'kpaa'];

  static const List<Map<String, double>> _steamTable = [
    {'bara': 0.5, 'tsat': 80.9, 'hfg': 2305},
    {'bara': 1.0, 'tsat': 99.6, 'hfg': 2257},
    {'bara': 1.5, 'tsat': 111.4, 'hfg': 2226},
    {'bara': 2.0, 'tsat': 120.2, 'hfg': 2202},
    {'bara': 2.5, 'tsat': 127.4, 'hfg': 2183},
    {'bara': 3.0, 'tsat': 133.5, 'hfg': 2163},
    {'bara': 4.0, 'tsat': 143.6, 'hfg': 2133},
    {'bara': 5.0, 'tsat': 151.8, 'hfg': 2108},
    {'bara': 6.0, 'tsat': 158.8, 'hfg': 2085},
    {'bara': 8.0, 'tsat': 170.4, 'hfg': 2047},
    {'bara': 10.0, 'tsat': 179.9, 'hfg': 2015},
    {'bara': 12.0, 'tsat': 188.0, 'hfg': 1984},
    {'bara': 15.0, 'tsat': 198.3, 'hfg': 1945},
    {'bara': 20.0, 'tsat': 212.4, 'hfg': 1889},
    {'bara': 30.0, 'tsat': 233.8, 'hfg': 1794},
    {'bara': 40.0, 'tsat': 250.3, 'hfg': 1714},
    {'bara': 50.0, 'tsat': 263.9, 'hfg': 1641},
  ];

  double _toDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.')) ?? 0;
  }

  double _clampDouble(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  bool get _isArrastreProcess {
    return [
      'Bota de condensado',
      'Separador de humedad',
      'Final de línea',
    ].contains(selectedProcess);
  }

  double get _bara {
    return _pressureToBara(_toDouble(pressureController.text), selectedUnd);
  }

  double get _tsat {
    return _tsatFromBara(_bara);
  }

  double get _hfg {
    return _hfgFromBara(_bara);
  }

  double get _cargaEstimada {
    if (selectedType == 'CALENTAMIENTO') {
      return _condensateFromHeating(
        massKg: _toDouble(masaController.text),
        cpKjKgK: _toDouble(cpController.text) == 0
            ? 4.186
            : _toDouble(cpController.text),
        tempInicialC: _toDouble(tempIniController.text),
        tempFinalC: _toDouble(tempFinController.text),
        timeMin: _toDouble(tiempoController.text),
        hfgKjKg: _hfg,
        xQuality: _xQuality,
      );
    }

    final pct =
        _clampDouble(_toDouble(porcentajeArrastreController.text), 0, 100) /
        100;

    final base = flowMode == 'CALDERA'
        ? _toDouble(boilerCapController.text)
        : _toDouble(flujoLineaController.text);

    return base * pct;
  }

  double get _cargaConFs {
    return _cargaEstimada * 1.5;
  }

  double _condensateFromHeating({
    required double massKg,
    required double cpKjKgK,
    required double tempInicialC,
    required double tempFinalC,
    required double timeMin,
    required double hfgKjKg,
    required double xQuality,
  }) {
    if (massKg <= 0) return 0;
    if (cpKjKgK <= 0) return 0;
    if (timeMin <= 0) return 0;
    if (hfgKjKg <= 0) return 0;
    if (xQuality <= 0) return 0;
    if (tempFinalC <= tempInicialC) return 0;

    final energiaKj = massKg * cpKjKgK * (tempFinalC - tempInicialC);
    final vaporKg = energiaKj / (hfgKjKg * xQuality);
    final vaporKgHora = vaporKg / (timeMin / 60);

    return vaporKgHora;
  }

  double _pressureToBara(double pressure, String unit) {
    switch (unit.toLowerCase()) {
      case 'psig':
        return (pressure + 14.6959) * 0.0689476;
      case 'barg':
        return pressure + 1.01325;
      case 'kpag':
        return (pressure / 100) + 1.01325;
      case 'psia':
        return pressure * 0.0689476;
      case 'bara':
        return pressure;
      case 'kpaa':
        return pressure / 100;
      default:
        return pressure;
    }
  }

  double _baraToPressure(double bara, String unit) {
    switch (unit.toLowerCase()) {
      case 'psig':
        return (bara / 0.0689476) - 14.6959;
      case 'barg':
        return bara - 1.01325;
      case 'kpag':
        return (bara - 1.01325) * 100;
      case 'psia':
        return bara / 0.0689476;
      case 'bara':
        return bara;
      case 'kpaa':
        return bara * 100;
      default:
        return bara;
    }
  }

  double _interpolateSteamValue(double bara, String field) {
    if (bara <= _steamTable.first['bara']!) {
      return _steamTable.first[field]!;
    }

    if (bara >= _steamTable.last['bara']!) {
      return _steamTable.last[field]!;
    }

    for (int i = 0; i < _steamTable.length - 1; i++) {
      final a = _steamTable[i];
      final b = _steamTable[i + 1];

      final baraA = a['bara']!;
      final baraB = b['bara']!;

      if (bara >= baraA && bara <= baraB) {
        final valueA = a[field]!;
        final valueB = b[field]!;
        final factor = (bara - baraA) / (baraB - baraA);

        return valueA + ((valueB - valueA) * factor);
      }
    }

    return 0;
  }

  double _tsatFromBara(double bara) {
    return _interpolateSteamValue(bara, 'tsat');
  }

  double _hfgFromBara(double bara) {
    return _interpolateSteamValue(bara, 'hfg');
  }

  String _recommendedTrap(String process) {
    switch (process) {
      case 'Marmita':
      case 'Intercambiador (placas/tubos)':
        return 'Flotador y termostática';

      case 'Rotatubos':
      case 'Rotadiscos':
      case 'Peletizadora':
      case 'Extrusora':
      case 'Separador de humedad':
        return 'Balde invertido';

      case 'Bota de condensado':
      case 'Final de línea':
      case 'Vapor sobrecalentado >200 PSI':
        return 'Termodinámica';

      default:
        return 'Termodinámica';
    }
  }

  String _fmt(double value, [int decimals = 2]) {
    if (value.isNaN || value.isInfinite) return '-';
    return value.toStringAsFixed(decimals);
  }

  @override
  void dispose() {
    _resultDebounce?.cancel();
    _resultTick.dispose();

    pressureController.dispose();
    materialController.dispose();
    masaController.dispose();
    tempIniController.dispose();
    tempFinController.dispose();
    tiempoController.dispose();
    cpController.dispose();
    porcentajeArrastreController.dispose();
    flujoLineaController.dispose();
    boilerCapController.dispose();
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

                if (_isArrastreProcess) {
                  selectedType = 'ARRASTRE';
                }
              });
            },
          ),
          const SizedBox(height: 14),
          _pressureCard(),
          const SizedBox(height: 14),
          _calculationCard(),
          const SizedBox(height: 14),
          ValueListenableBuilder<int>(
            valueListenable: _resultTick,
            builder: (context, value, child) {
              return _recommendationCard();
            },
          ),
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
                  'Se usa Tsat por tabla',
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
                    SizedBox(
                      width: 220,
                      child: _appDropdownWithLabel(
                        label: 'Unidad',
                        value: selectedUnd,
                        items: listUnd,
                        onChanged: (value) {
                          setState(() => selectedUnd = value!);
                        },
                      ),
                    ),
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
                  _appDropdownWithLabel(
                    label: 'Unidad',
                    value: selectedUnd,
                    items: listUnd,
                    onChanged: (value) {
                      setState(() => selectedUnd = value!);
                    },
                  ),
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
                    _modeSelector(),
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
                  _modeSelector(),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: selectedType == 'CALENTAMIENTO'
                ? _heatingFields()
                : _dragFields(),
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
        _appInput(
          label: 'Material / fluido',
          controller: materialController,
          keyboardType: TextInputType.text,
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
                    label: 'Masa a calentar (kg) *',
                    controller: masaController,
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
                SizedBox(
                  width: itemWidth,
                  child: _appInput(
                    label: 'cp (kJ/kg·K)',
                    controller: cpController,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          '*Si no se conoce la masa, usa un valor representativo y luego ajusta en visita técnica.',
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
        if (!_isArrastreProcess) ...[
          Text(
            'El modo “Arrastre” aplica principalmente para botas, separadores y finales de línea.',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 430;

            final baseDropdown = _flowModeDropdown();

            final carryPctInput = _appInput(
              label: '% arrastre (10–15%)',
              controller: porcentajeArrastreController,
            );

            final baseInput = flowMode == 'CALDERA'
                ? _appInput(
                    label: 'Capacidad caldera (kg/h)',
                    controller: boilerCapController,
                  )
                : _appInput(
                    label: 'Flujo en línea (kg/h)',
                    controller: flujoLineaController,
                  );

            final note = Text(
              'Carga ≈ flujo base × (%arrastre) y luego FS=1.5.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.muted,
                height: 1.35,
              ),
            );

            if (isWide) {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: baseDropdown),
                      const SizedBox(width: 12),
                      Expanded(child: carryPctInput),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: baseInput),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 28),
                          child: note,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }

            return Column(
              children: [
                baseDropdown,
                const SizedBox(height: 14),
                carryPctInput,
                const SizedBox(height: 14),
                baseInput,
                const SizedBox(height: 10),
                note,
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _recommendationCard() {
    final rec = _recommendedTrap(selectedProcess);
    final pressureInSelectedUnit = _baraToPressure(_bara, selectedUnd);

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
            'Presión: ${_fmt(pressureInSelectedUnit, 3)} $selectedUnd (≈ ${_fmt(_bara, 3)} bara)',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            'Tsat: ${_fmt(_tsat, 1)} °C · hfg ≈ ${_fmt(_hfg, 0)} kJ/kg',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 14),
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
                  title: 'Carga con FS=1.5',
                  value: '${_fmt(_cargaConFs, 2)} kg/h',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Calidad de vapor asumida (calentamiento): ${(_xQuality * 100).toStringAsFixed(0)}%. hfg usado según presión (tabla aprox).',
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

  Widget _modeSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffdce6f2)),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tabButton(mode: 'CALENTAMIENTO', label: 'Calentamiento'),
          _tabButton(mode: 'ARRASTRE', label: 'Arrastre (10–15%)'),
        ],
      ),
    );
  }

  Widget _tabButton({required String mode, required String label}) {
    final bool isSelected = selectedType == mode;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() => selectedType = mode);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff07101f) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xff344563),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _flowModeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Base del cálculo'),
        const SizedBox(height: 8),
        Container(
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
              value: flowMode,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xff07142b),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'CALDERA',
                  child: Text(
                    'Capacidad de caldera (kg/h)',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                DropdownMenuItem(
                  value: 'LINEA',
                  child: Text(
                    'Flujo en línea (kg/h)',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => flowMode = value!);
              },
            ),
          ),
        ),
      ],
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
