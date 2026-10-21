import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/presentation/providers/auth_provider.dart';
import 'package:tuvalapp/presentation/shared/widgets/app_toast.dart';

class BiometricSettingsTile extends StatelessWidget {
  const BiometricSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.biometricAvailable && !auth.biometricEnabled) {
      return const SizedBox.shrink();
    }
    return SwitchListTile(
      secondary: const Icon(Icons.fingerprint),
      title: const Text('Acceso biométrico'),
      subtitle: const Text(
        'Solicitar al volver a abrir la app. Cerrar sesión desactiva esta opción.',
      ),
      value: auth.biometricEnabled,
      onChanged: auth.isPosting
          ? null
          : (value) async {
              final saved = await auth.setBiometricEnabled(value);
              if (!context.mounted) return;
              if (saved) {
                AppToast.success(
                  context,
                  value
                      ? 'Acceso biométrico activado.'
                      : 'Acceso biométrico desactivado.',
                );
              } else if (auth.errorMessage != null) {
                AppToast.error(context, auth.errorMessage!);
              }
            },
    );
  }
}
