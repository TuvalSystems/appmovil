import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuvalapp/infrastructure/services/app_update_service.dart';

class AppUpdateDialog extends StatelessWidget {
  final AppUpdateResult result;

  const AppUpdateDialog({
    super.key,
    required this.result,
  });

  Future<void> _downloadApk(BuildContext context) async {
    final url = result.latest.apkUrl;

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró la URL de descarga.'),
        ),
      );
      return;
    }

    final uri = Uri.parse(url);

    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el enlace de descarga.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRequired = result.isRequired;

    return PopScope(
      canPop: !isRequired,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        title: Row(
          children: [
            Icon(
              isRequired ? Icons.system_update_alt : Icons.download_rounded,
              color: isRequired ? Colors.redAccent : Colors.blueAccent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isRequired
                    ? 'Actualización requerida'
                    : 'Nueva versión disponible',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.latest.message?.isNotEmpty == true
                  ? result.latest.message!
                  : 'Hay una nueva versión de la aplicación disponible para descargar.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Versión instalada',
                    value: '${result.currentVersion}+${result.currentBuild}',
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    label: 'Nueva versión',
                    value:
                        '${result.latest.latestVersion}+${result.latest.latestBuild}',
                  ),
                ],
              ),
            ),
            if (result.latest.releaseNotes?.isNotEmpty == true) ...[
              const SizedBox(height: 14),
              const Text(
                'Notas de versión',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                result.latest.releaseNotes!,
                style: const TextStyle(fontSize: 13),
              ),
            ],
            if (isRequired) ...[
              const SizedBox(height: 14),
              const Text(
                'Para continuar usando la aplicación debes instalar esta actualización.',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!isRequired)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Luego'),
            ),
          ElevatedButton.icon(
            onPressed: () => _downloadApk(context),
            icon: const Icon(Icons.download),
            label: const Text('Descargar'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}