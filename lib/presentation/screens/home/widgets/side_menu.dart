import 'package:tuvalapp/presentation/screens/auth/widgets/biometric_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/infrastructure/models/menu/app_menu_model.dart';
import 'package:tuvalapp/presentation/providers/auth_provider.dart';
import 'package:tuvalapp/presentation/providers/point_sales_provider.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/side_menu_header.dart';
import 'package:tuvalapp/presentation/shared/helpers/mobile_menu_mapper.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final fullName = user?.fullName ?? 'Usuario';
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final menuItems = authProvider.appMenu?.items ?? [];
    //nuevo drawer menu
    return Drawer(
      child: Column(
        children: [
          SideMenuHeader(fullName: fullName),

          //SECCION DE NAVEGACIÓN
          Expanded(
            child: menuItems.isEmpty
                ? _EmptyMenuMessage()
                : ListView(
                    padding: EdgeInsets.zero,
                    children: menuItems
                        .map(
                          (item) => _buildMenuItem(context, item, currentRoute),
                        )
                        .toList(),
                  ),
          ),

          // --- BOTÓN DE CIERRE DE SESIÓN ---
          Divider(),
          const BiometricSettingsTile(),
          _SafeLogout(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  //limpieza de menu
  Widget _buildMenuItem(
    BuildContext context,
    AppMenuItem item,
    String? currentRoute,
  ) {
    final hasChildren = item.children.isNotEmpty;
    final isActive = _isMenuItemActive(item, currentRoute);

    if (hasChildren) {
      return ExpansionTile(
        key: PageStorageKey(item.key),
        initiallyExpanded: isActive,
        leading: Icon(
          MobileMenuMapper.resolveIcon(item.icon),
          size: 20,
          color: isActive ? AppColors.brand : context.appColors.muted,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.brand : context.appColors.muted,
          ),
        ),
        iconColor: AppColors.brand,
        collapsedIconColor: AppColors.brand,
        textColor: AppColors.brand,
        collapsedTextColor: AppColors.brand,
        childrenPadding: EdgeInsets.only(left: 20),
        children: item.children.map((child) {
          final childHasChildren = child.children.isNotEmpty;

          if (childHasChildren) {
            return _buildMenuItem(context, child, currentRoute);
          }

          return _SubMenuItem(
            icon: MobileMenuMapper.resolveIcon(child.icon),
            label: child.label,
            isActive: _isMenuItemActive(child, currentRoute),
            onTap: () => _navigateToItem(context, child, currentRoute),
          );
        }).toList(),
      );
    }

    return _DrawerItem(
      icon: MobileMenuMapper.resolveIcon(item.icon),
      label: item.label,
      isActive: isActive,
      onTap: () => _navigateToItem(context, item, currentRoute),
    );
  }

  static bool _isMenuItemActive(AppMenuItem item, String? currentRoute) {
    final targetRoute = MobileMenuMapper.resolveRoute(item.route);

    if (_isSameRoute(targetRoute, currentRoute)) {
      return true;
    }

    return item.children.any((child) => _isMenuItemActive(child, currentRoute));
  }

  static bool _isSameRoute(String? targetRoute, String? currentRoute) {
    if (targetRoute == null) return false;

    if (targetRoute == Navigator.defaultRouteName) {
      return currentRoute == null || currentRoute == Navigator.defaultRouteName;
    }

    return currentRoute == targetRoute;
  }

  static void _navigateToItem(
    BuildContext context,
    AppMenuItem item,
    String? currentRoute,
  ) {
    final targetRoute = MobileMenuMapper.resolveRoute(item.route);
    if (targetRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ruta no configurada: ${item.label}')),
      );
      return;
    }
    Navigator.pop(context);
    if (_isSameRoute(targetRoute, currentRoute)) return;

    if (targetRoute == Navigator.defaultRouteName) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    Navigator.pushNamed(context, targetRoute);
  }
}

class _EmptyMenuMessage extends StatelessWidget {
  const _EmptyMenuMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No hay opciones de menú disponibles.',
          textAlign: TextAlign.center,
          style: TextStyle(color: context.appColors.muted, fontSize: 13),
        ),
      ),
    );
  }
}

class _SafeLogout extends StatelessWidget {
  const _SafeLogout();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListTile(
        dense: true,
        leading: Icon(Icons.logout),
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          final navigator = Navigator.of(context);
          final authProvider = context.read<AuthProvider>();
          final pointProvider = context.read<PointSalesProvider>();
          navigator.pop();
          navigator.popUntil((route) => route.isFirst);
          await pointProvider.clearPointSales();
          await authProvider.logout();
        },
      ),
    );
  }
}

//widget para menu sin submenu
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.brand : context.appColors.muted;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity(vertical: -4),
      selected: isActive,
      selectedTileColor: context.appColors.brandSoft,
      leading: Icon(icon, color: color, size: 20),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

// NUEVO: Widget para las opciones de segundo nivel (sub-menú)
class _SubMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _SubMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.brand : context.appColors.muted;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity(vertical: -4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        selected: isActive,
        selectedTileColor: context.appColors.brandSoft,
        leading: Icon(icon, color: color, size: 16),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
