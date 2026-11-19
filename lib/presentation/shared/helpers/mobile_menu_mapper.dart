import 'package:flutter/material.dart';
import 'package:tuvalapp/config/router/app_router.dart';
import 'package:tuvalapp/infrastructure/models/menu/app_menu_model.dart';

class MobileMenuMapper {
  static const branchSalesMenuRoute = 'app.sales.branch_sales.index';
  static bool isBranchSalesAdministrator(String? profileName) =>
      profileName?.trim() == 'Administrador';

  // Agrupa únicamente opciones concedidas por el backend; no concede acceso.
  // Conserva la ruta backend vigente para no cambiar el contrato de permisos.
  static List<AppMenuItem> organizeReports(List<AppMenuItem> items) {
    final reportItems = items
        .where((item) => item.route == branchSalesMenuRoute)
        .toList();
    if (reportItems.isEmpty) return items;

    final result = items
        .where((item) => item.route != branchSalesMenuRoute)
        .toList();
    final index = result.indexWhere(
      (item) => item.label.trim().toLowerCase() == 'reportes',
    );
    final parent = index < 0 ? null : result[index];
    bool containsReport(AppMenuItem item) =>
        item.route == branchSalesMenuRoute || item.children.any(containsReport);
    final group = AppMenuItem(
      id: parent?.id ?? 0,
      key: parent?.key ?? 'mobile_reports',
      label: parent?.label ?? 'Reportes',
      icon: parent?.icon ?? 'assessment',
      route: parent?.route,
      children: [
        ...?parent?.children,
        if (parent == null || !containsReport(parent)) reportItems.first,
      ],
    );
    if (index < 0) {
      result.insert(
        items.indexOf(reportItems.first).clamp(0, result.length),
        group,
      );
    } else {
      result[index] = group;
    }
    return result;
  }

  static IconData resolveIcon(String? icon) {
    switch (icon) {
      case 'assessment':
        return Icons.assessment_outlined;
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
      case branchSalesMenuRoute:
        return AppRouter.branchSales;
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
