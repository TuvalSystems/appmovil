import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/widgets/steam_trap_main_card.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/side_menu.dart';

class SteamTrapsScreen extends StatelessWidget {
  const SteamTrapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SteamTrapProvider(),
      child: const _SteamTrapsView(),
    );
  }
}

class _SteamTrapsView extends StatelessWidget {
  const _SteamTrapsView();

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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: const ScrollConfiguration(
          behavior: _NoStretchScrollBehavior(),
          child: SingleChildScrollView(
            keyboardDismissBehavior:  ScrollViewKeyboardDismissBehavior.onDrag,
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
