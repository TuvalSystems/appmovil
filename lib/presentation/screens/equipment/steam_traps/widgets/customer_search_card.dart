import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';
import 'package:tuvalapp/presentation/shared/widgets/customer_search_card.dart'
    as shared;

class CustomerSearchCard extends StatelessWidget {
  const CustomerSearchCard({super.key});

  @override
  Widget build(BuildContext context) => shared.CustomerSearchCard(
    controller: context.read<SteamTrapProvider>().customerSearch,
    description:
        'Busque y seleccione el cliente sobre el cual se aplicará este dimensionamiento.',
  );
}
