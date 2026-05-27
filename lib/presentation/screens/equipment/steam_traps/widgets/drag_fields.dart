import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/steam_trap_input.dart';

class DragFields extends StatelessWidget {
  const DragFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SteamTrapProvider>();

    return Column(
      key: const ValueKey('arrastre'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Si conoce la carga de condensado del punto, ingrésela directamente. '
          'Si no, ingrese la capacidad del caldero en BHP.',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        SteamTrapInput(
          label: 'Carga conocida del punto (kg/h)',
          controller: provider.knownLoadController,
          onChanged: provider.clearGeneratedResult,
        ),
        const SizedBox(height: 14),
        SteamTrapInput(
          label: 'Capacidad de caldera (BHP)',
          controller: provider.boilerBhpController,
          onChanged: provider.clearGeneratedResult,
        ),
        const SizedBox(height: 10),
        Text(
          'Si no se ingresa carga conocida, se estima: '
          '0.15 × BHP × 15.65 = 2.35 × BHP.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.muted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}