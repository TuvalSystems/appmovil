import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/constants/steam_traps_catalogs.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/calculation_card.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/customer_search_card.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/pressure_card.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/recommendation_card.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/steam_trap_dropdown.dart';

class SteamTrapMainCard extends StatelessWidget {
  const SteamTrapMainCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SteamTrapProvider>();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColors.border, width: 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trampas de vapor (selector rápido)',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: context.appColors.text,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Calcula una carga estimada y sugiere tipo de trampa según el proceso.',
            style: TextStyle(color: context.appColors.muted, fontSize: 13),
          ),
          SizedBox(height: 16),
          CustomerSearchCard(),
          SizedBox(height: 14),
          Text(
            'Proceso / aplicación',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: context.appColors.muted,
            ),
          ),
          SizedBox(height: 8),
          SteamTrapDropdown(
            value: provider.selectedProcess,
            items: SteamTrapsCatalogs.processes,
            onChanged: (value) {
              if (value == null) return;
              provider.setProcess(value);
            },
          ),
          SizedBox(height: 14),
          PressureCard(),
          SizedBox(height: 14),
          CalculationCard(),
          SizedBox(height: 14),
          RecommendationCard(),
        ],
      ),
    );
  }
}
