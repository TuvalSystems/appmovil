import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/drag_fields.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/heating_fields.dart';

class CalculationCard extends StatelessWidget {
  const CalculationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SteamTrapProvider>();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 430;

              final routeText = provider.isHeatingProcess
                  ? 'Ruta: calentamiento indirecto'
                  : 'Ruta: drenaje / arrastre';
              if (isWide) {
                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Cálculo de carga',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff07142b),
                        ),
                      ),
                    ),
                    _RouteBadge(text: routeText),
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
                  _RouteBadge(text: routeText),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: provider.isHeatingProcess
                ? const HeatingFields()
                : const DragFields(),
          ),
        ],
      ),
    );
  }
}

class _RouteBadge extends StatelessWidget {
  final String text;

  const _RouteBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffeef3f9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xff07142b),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
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
}
