import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/steam_trap_input.dart';

class PressureCard extends StatelessWidget {
  const PressureCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SteamTrapProvider>();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Datos de presión',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
                      child: SteamTrapInput(
                        label: 'Presión de trabajo',
                        controller: provider.pressureController,
                        onChanged: provider.clearGeneratedResult,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SteamTrapInput(
                        label: 'Presión de retorno',
                        controller: provider.returnPressureController,
                        onChanged: provider.clearGeneratedResult,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const SizedBox(width: 100, child: _UnitBadge()),
                  ],
                );
              }
              return Column(
                children: [
                  SteamTrapInput(
                    label: 'Presión de Trabajo',
                    controller: provider.pressureController,
                    onChanged: provider.clearGeneratedResult,
                  ),
                  const SizedBox(height: 12),
                  SteamTrapInput(
                    label: 'Presión de retorno',
                    controller: provider.returnPressureController,
                    onChanged: provider.clearGeneratedResult,
                  ),
                  const SizedBox(height: 12),
                  const _UnitBadge(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UnitBadge extends StatelessWidget {
  const _UnitBadge();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Unidad'),
        const SizedBox(height: 8,),
        Container(
          height: 46,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xffdce6f2),
            ),
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
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xfffbfdff),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xffdce6f2),
        ),
      ),
      child: child,
    );
  }
}
class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
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