import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/constants/steam_traps_catalogs.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/steam_trap_dropdown.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/steam_trap_input.dart';

class HeatingFields extends StatelessWidget {
  const HeatingFields({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SteamTrapProvider>();

    return Column(
      key: const ValueKey('calentamiento'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SteamTrapDropdown(
          label: 'Fluido a calentar',
          value: provider.selectedFluid,
          items: SteamTrapsCatalogs.fluids,
          onChanged: (value) {
            if (value == null) return;
            provider.setFluid(value);
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
                  child: SteamTrapInput(
                    label: 'Volumen (m³) *',
                    controller: provider.volumeController,
                    onChanged: provider.clearGeneratedResult,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: SteamTrapInput(
                    label: 'Temp. inicial (°C)',
                    controller: provider.tempIniController,
                    onChanged: provider.clearGeneratedResult,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: SteamTrapInput(
                    label: 'Temp. final (°C)',
                    controller: provider.tempFinController,
                    onChanged: provider.clearGeneratedResult,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: SteamTrapInput(
                    label: 'Tiempo (min)',
                    controller: provider.tiempoController,
                    onChanged: provider.clearGeneratedResult,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        Text(
          'Cp: ${provider.fmt(provider.cp, 2)} kJ/kg·°C · '
          'Densidad: ${provider.fmt(provider.rho, 0)} kg/m³ · '
          'Masa calculada: ${provider.fmt(provider.massKg, 2)} kg',
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