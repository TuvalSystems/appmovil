import 'package:flutter/material.dart';
import 'package:tuvalapp/config/router/app_router.dart';

class MobileMenuMapper {
  static IconData resolveIcon(String? icon) {
    switch (icon) {
      case 'dashboard':
        return Icons.dashboard_customize_outlined;
      case 'precision_manufacturing':
        return Icons.precision_manufacturing_outlined;
      case 'local_shipping':
        return Icons.local_shipping_outlined;
      case 'warehouse':
        return Icons.warehouse_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  static String? resolveRoute(String? backendRoute) {
    switch (backendRoute) {
      case 'app.home':
        return Navigator.defaultRouteName;
      case 'app.inventory.delivery_notes.index':
        return AppRouter.deliveryNotes;
      case 'app.equipment.steam_traps.index':
        return AppRouter.steamTraps;
      default:
        return null;
    }
  }
}
