import 'package:flutter/material.dart';
import 'package:tuvalapp/presentation/screens/auth/login_screen.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/steam_traps_screen.dart';
import 'package:tuvalapp/presentation/screens/home/home_screen.dart';

class AppRouter {
  static const String initialRoute = 'login';
  static const String home = 'home';
  static const String steamTraps = '/steam-traps';
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      //auth
      initialRoute: (context) => const LoginScreen(),
      //pages
      home: (context) => const HomeScreen(),
      steamTraps: (context) => const SteamTrapsScreen(), // Aquí puedes reemplazar con tu pantalla de inventario
    };
  }
}
