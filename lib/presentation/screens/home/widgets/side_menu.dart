import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/router/app_router.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';

import 'package:tuvalapp/presentation/providers/auth_provider.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/user_initials_avatar.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final fullName = user?.fullName ?? 'Usuario';
    final currentRoute = ModalRoute.of(context)?.settings.name;
    //nuevo drawer menu
    return Drawer(
      child: Column(
        children: [
          _SideMenuHeader(fullName: fullName),

          //SECCION DE NAVEGACIÓN
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_customize_outlined,
                  label: 'Dashboard',
                  isActive:
                      currentRoute == null ||
                      currentRoute == Navigator.defaultRouteName,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                //Item de segundo nivel (Colpasable)
                ExpansionTile(
                  leading: const Icon(
                    Icons.precision_manufacturing_outlined,
                    color: AppColors.brand,
                    size: 20,
                  ),
                  title: const Text(
                    'Gestión de Equipos',
                    style: TextStyle(color: AppColors.brand, fontSize: 14),
                  ),
                  iconColor: AppColors.brand,
                  collapsedIconColor: AppColors.brand,
                  childrenPadding: const EdgeInsets.only(left: 20),
                  children: [
                    _SubMenuItem(
                      label: 'Trampas de Vapor',
                      isActive: true,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, AppRouter.steamTraps);
                      },
                    ),
                  ],
                ),
                //aqui agregar otro drawItem o ExpansionTitle
              ],
            ),
          ),

          // --- BOTÓN DE CIERRE DE SESIÓN ---
          const Divider(color: AppColors.border),
          const _SafeLogout(),
          const SizedBox(height: 10),
        ],
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
        leading: const Icon(Icons.logout, color: AppColors.brand),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: AppColors.brand, fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          final navigator = Navigator.of(context);
          final authProvider = context.read<AuthProvider>();
          navigator.pop();
          navigator.popUntil((route) => route.isFirst);
          await authProvider.logout();
        },
      ),
    );
  }
}

class _SideMenuHeader extends StatelessWidget {
  final String fullName;

  const _SideMenuHeader({required this.fullName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 42, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.brand,
        border: Border(bottom: BorderSide(color: AppColors.brand, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserInitialsAvatar(
            name: fullName,
            radius: 30,
            backgroundColor: AppColors.card,
            textColor: AppColors.brand,
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            style: const TextStyle(
              color: AppColors.onBrand,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
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
    final color = isActive ? AppColors.brand : AppColors.muted;

    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      selected: isActive,
      selectedTileColor: AppColors.brandSoft,
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
  final String label;
  final VoidCallback onTap;
  final bool isActive; // 1. Nueva propiedad para saber si es la pantalla actual

  const _SubMenuItem({
    required this.label,
    required this.onTap,
    this.isActive = false, // Por defecto es falso
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.brand : AppColors.muted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -4),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),

        selected: isActive,
        selectedTileColor: AppColors.brand.withValues(alpha: 0.1),

        leading: Icon(Icons.subdirectory_arrow_right, color: color, size: 16),
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
