import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/router/app_router.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';

import 'package:tuvalapp/presentation/providers/auth_provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    //nuevo drawer menu
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.brand,
              border: Border(
                bottom: BorderSide(
                  color: AppColors.card,
                  width: 0.5,
                ), // Una línea neón sutil
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.card,
              child: Icon(Icons.person, color: AppColors.brand, size: 30),
            ),
            accountName: Text(
              user?.fullName ?? 'Cargando...',
              style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              'ID: ${user?.loginId ?? '---'}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),

          //SECCION DE NAVEGACIÓN
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.dashboard_customize_outlined,
                  label: 'Dashboard',
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

//widget para menu sin submenu
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -4),
      leading: Icon(icon, color: AppColors.brand, size: 20),
      title: Text(
        label,
        style: TextStyle(color: AppColors.brand, fontSize: 14),
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
