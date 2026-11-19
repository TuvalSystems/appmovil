import 'package:tuvalapp/presentation/screens/reports/sales/branch_sales/branch_sales_screen.dart';
import 'package:tuvalapp/presentation/screens/inventory/delivery_note/delivery_notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:tuvalapp/presentation/screens/auth/login_screen.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/steam_traps_screen.dart';
import 'package:tuvalapp/presentation/screens/home/home_screen.dart';

class AppRouter {
  static const String initialRoute = 'login';
  static const String home = 'home';
  static const String steamTraps = '/steam-traps';
  static const String deliveryNotes = '/inventory/delivery-notes';
  static const String branchSales = '/reports/sales/branch-sales';
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      //auth
      initialRoute: (context) => const LoginScreen(),
      deliveryNotes: (context) => const DeliveryNotesScreen(),
      branchSales: (context) => const BranchSalesScreen(),
      // Compatibilidad con enlaces internos anteriores a la clasificación.
      '/sales/branch-sales': (context) => const BranchSalesScreen(),
      //pages
      home: (context) => const HomeScreen(),
      steamTraps: (context) =>
          const SteamTrapsScreen(), // Aquí puedes reemplazar con tu pantalla de inventario
    };
  }
}
