import 'package:flutter/material.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/infrastructure/services/app_update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateDialog extends StatefulWidget {
  final AppUpdateResult result;
  const AppUpdateDialog({super.key, required this.result});

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  bool _opening = false;
  String? _error;

  Future<void> _downloadApk() async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _error = null;
    });
    try {
      final uri = Uri.tryParse(widget.result.latest.apkUrl.trim());
      if (uri == null ||
          !uri.hasAuthority ||
          (uri.scheme != 'https' && uri.scheme != 'http')) {
        throw StateError('No se encontró un enlace de descarga válido.');
      }
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw StateError('No se pudo abrir la descarga. Intente nuevamente.');
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is StateError
              ? error.message.toString()
              : 'No se pudo abrir la descarga. Intente nuevamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final colors = context.appColors;
    final message = result.latest.message?.trim();
    final notes = result.latest.releaseNotes?.trim();
    final size = result.latest.apkSizeBytes;
    final downloadLabel = size != null && size > 0
        ? 'Descargar actualización · ${(size / (1024 * 1024)).toStringAsFixed(1)} MB'
        : 'Descargar actualización';

    return PopScope(
      canPop: !result.isRequired && !_opening,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 440,
            maxHeight: MediaQuery.sizeOf(context).height * .85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(24, 20, 20, 24),
                        color: colors.brandSoft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.brand,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.system_update_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                const Spacer(),
                                if (!result.isRequired)
                                  IconButton(
                                    tooltip: 'Cerrar',
                                    onPressed: _opening
                                        ? null
                                        : () => Navigator.of(context).pop(),
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              result.isRequired
                                  ? 'ACTUALIZACIÓN NECESARIA'
                                  : 'NUEVA VERSIÓN',
                              style: const TextStyle(
                                color: AppColors.brand,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tuval sigue mejorando',
                              style: TextStyle(
                                color: colors.text,
                                fontSize: 25,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              message?.isNotEmpty == true
                                  ? message!
                                  : 'Ya está disponible una nueva versión. Actualiza la app para disfrutar de las últimas mejoras.',
                              style: TextStyle(
                                color: colors.muted,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: _VersionCard(
                                    label: 'Tu versión',
                                    version: result.currentVersion,
                                    buildNumber: result.currentBuild,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                    color: colors.muted,
                                  ),
                                ),
                                Expanded(
                                  child: _VersionCard(
                                    label: 'Disponible',
                                    version: result.latest.latestVersion,
                                    buildNumber: result.latest.latestBuild,
                                    highlighted: true,
                                  ),
                                ),
                              ],
                            ),
                            if (notes?.isNotEmpty == true) ...[
                              const SizedBox(height: 22),
                              Text(
                                'Qué hay de nuevo',
                                style: TextStyle(
                                  color: colors.text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                notes!,
                                style: TextStyle(
                                  color: colors.muted,
                                  fontSize: 14,
                                  height: 1.55,
                                ),
                              ),
                            ],
                            if (result.isRequired) ...[
                              const SizedBox(height: 18),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.pill,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      size: 18,
                                      color: AppColors.brand,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Instala esta versión para continuar usando Tuval.',
                                        style: TextStyle(
                                          color: colors.text,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_error != null) ...[
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _opening ? null : _downloadApk,
                      icon: _opening
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download_rounded, size: 21),
                      label: Text(
                        _opening ? 'Abriendo descarga…' : downloadLabel,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Se abrirá el navegador para descargar e instalar la nueva versión.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    if (!result.isRequired) ...[
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: _opening
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Ahora no'),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionCard extends StatelessWidget {
  final String label;
  final String version;
  final int buildNumber;
  final bool highlighted;
  const _VersionCard({
    required this.label,
    required this.version,
    required this.buildNumber,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted ? colors.brandSoft : colors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? AppColors.brand.withValues(alpha: .3)
              : colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlighted ? AppColors.brand : colors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            version,
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Build $buildNumber',
            style: TextStyle(color: colors.muted, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
