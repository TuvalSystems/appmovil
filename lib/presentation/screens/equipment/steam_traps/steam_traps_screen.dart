import 'package:tuvalapp/infrastructure/datasources/customers_datasource.dart';
import 'package:tuvalapp/infrastructure/datasources/steam_trap_datasource.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/steam_trap_main_card.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/side_menu.dart';
import 'package:tuvalapp/presentation/shared/widgets/tuval_app_bar.dart';

class SteamTrapsScreen extends StatelessWidget {
  const SteamTrapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SteamTrapProvider(
        steamTrapDataSource: context.read<SteamTrapDatasource>(),
        customersDatasource: context.read<CustomersDatasource>(),
      ),
      child: _SteamTrapsView(),
    );
  }
}

class _SteamTrapsView extends StatelessWidget {
  const _SteamTrapsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bg,
      drawer: SideMenu(),
      appBar: TuvalAppBar(title: 'Trampas de Vapor'),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: ScrollConfiguration(
          behavior: _NoStretchScrollBehavior(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: SteamTrapMainCard(),
          ),
        ),
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
