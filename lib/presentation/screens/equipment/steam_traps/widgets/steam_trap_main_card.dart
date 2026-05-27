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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffdce6f2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
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
          const CustomerSearchCard(),
          const SizedBox(height: 14),
          const Text(
            'Proceso / aplicación',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Color(0xff344563),
            ),
          ),
          const SizedBox(height: 8),
          SteamTrapDropdown(
            value: provider.selectedProcess,
            items: SteamTrapsCatalogs.processes,
            onChanged: (value) {
              if (value == null) return;
              provider.setProcess(value);
            },
          ),
          const SizedBox(height: 14),
          const PressureCard(),
          const SizedBox(height: 14),
          const CalculationCard(),
          const SizedBox(height: 14),
          const RecommendationCard(),
        ],
      ),
    );
  }
}
