import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';
import 'package:tuvalapp/presentation/shared/widgets/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SteamTrapProvider>();
    final validationMessage = provider.validationMessage;
    final isBusy = provider.isSending || provider.isCreateQuote;
    final hasValidation = validationMessage != null;
    final canExecuteActions = !isBusy && !hasValidation;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff07101f),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(provider: provider),
          const SizedBox(height: 16),

          _TechnicalSummary(provider: provider),
          const SizedBox(height: 14),

          if (validationMessage != null)
            _ValidationBox(message: validationMessage)
          else
            _LoadResults(provider: provider),

          const SizedBox(height: 12),

          _FormulaBox(provider: provider),
          const SizedBox(height: 16),

          _ActionsBox(
            provider: provider,
            isBusy: isBusy,
            canExecuteActions: canExecuteActions,
            onOpenPdf: () => _openGeneratedPdf(context, provider),
          ),

          if (provider.sendMessage != null &&
              provider.sendMessage!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _MessageBox(
              message: provider.sendMessage!,
              type: provider.sendMessageType ?? AppToastType.info,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openGeneratedPdf(
    BuildContext context,
    SteamTrapProvider provider,
  ) async {
    final url = provider.generatedPdfUrl?.trim();

    if (url == null || url.isEmpty) {
      AppToast.error(context, 'No se encontró la URL del PDF generado.');
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null || !uri.hasScheme) {
      AppToast.error(context, 'La URL del PDF no es válida.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      AppToast.error(context, 'No se pudo abrir el PDF.');
    }
  }
}

class _Header extends StatelessWidget {
  final SteamTrapProvider provider;

  const _Header({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xff1d4ed8).withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xff60a5fa).withValues(alpha: 0.28),
            ),
          ),
          child: const Icon(
            Icons.engineering_outlined,
            color: Color(0xff93c5fd),
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recomendación técnica',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                provider.recommendedTrap,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  height: 1.05,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _MiniBadge(
          text: provider.isHeatingProcess ? 'Calentamiento' : 'Drenaje',
          color: provider.isHeatingProcess
              ? const Color(0xfff59e0b)
              : const Color(0xff22c55e),
        ),
      ],
    );
  }
}

class _TechnicalSummary extends StatelessWidget {
  final SteamTrapProvider provider;

  const _TechnicalSummary({required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = <_InfoMetric>[
      _InfoMetric(
        label: 'Presión trabajo',
        value: '${provider.fmt(provider.pressurePsig, 2)} PSIG',
        icon: Icons.speed_outlined,
      ),
      _InfoMetric(
        label: 'Presión retorno',
        value: '${provider.fmt(provider.returnPressurePsig, 2)} PSIG',
        icon: Icons.keyboard_return_rounded,
      ),
      _InfoMetric(
        label: 'Diferencial',
        value: '${provider.fmt(provider.pressureDifferentialPsig, 2)} PSIG',
        icon: Icons.compare_arrows_rounded,
      ),
      if (provider.isHeatingProcess)
        _InfoMetric(
          label: 'hfg',
          value: '${provider.fmt(provider.hfg, 1)} kJ/kg',
          icon: Icons.local_fire_department_outlined,
        ),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => _MetricChip(
              label: item.label,
              value: item.value,
              icon: item.icon,
            ),
          )
          .toList(),
    );
  }
}

class _LoadResults extends StatelessWidget {
  final SteamTrapProvider provider;

  const _LoadResults({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ResultBox(
            title: 'Carga estimada',
            value: '${provider.fmt(provider.cargaEstimada, 2)} kg/h',
            icon: Icons.water_drop_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ResultBox(
            title: 'Referencia FS=1.5',
            value: '${provider.fmt(provider.cargaConFs, 2)} kg/h',
            icon: Icons.verified_outlined,
          ),
        ),
      ],
    );
  }
}

class _FormulaBox extends StatelessWidget {
  final SteamTrapProvider provider;

  const _FormulaBox({required this.provider});

  @override
  Widget build(BuildContext context) {
    final formula = provider.isHeatingProcess
        ? 'Cálculo por energía: 60 × ρ × V × Cp × ΔT / (hfg × t min).'
        : 'Cálculo por drenaje: carga conocida o 0.15 × BHP × 15.65.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.functions_rounded, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$formula\nMétodo: ${provider.calculationMethod}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsBox extends StatelessWidget {
  final SteamTrapProvider provider;
  final bool isBusy;
  final bool canExecuteActions;
  final VoidCallback onOpenPdf;

  const _ActionsBox({
    required this.provider,
    required this.isBusy,
    required this.canExecuteActions,
    required this.onOpenPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xff111a2b),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_outlined, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                'Acciones',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          _ActionButton(
            enabled: canExecuteActions,
            loading: provider.isSending,
            loadingLabel: 'Generando PDF...',
            label: 'Generar PDF técnico',
            icon: Icons.picture_as_pdf_outlined,
            onPressed: () async {
              await provider.generateSizingPdf();

              if (!context.mounted) return;

              _showProviderMessage(context, provider);
            },
          ),

          if (provider.generatedPdfUrl != null &&
              provider.generatedPdfUrl!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _ActionButton(
              enabled: !isBusy,
              loading: false,
              label: 'Abrir PDF generado',
              icon: Icons.open_in_new_rounded,
              outlined: true,
              onPressed: onOpenPdf,
            ),
          ],

          const SizedBox(height: 10),

          _ActionButton(
            enabled: canExecuteActions,
            loading: provider.isCreateQuote,
            loadingLabel: 'Creando cotización...',
            label: 'Crear cotización borrador',
            icon: Icons.request_quote_outlined,
            onPressed: () async {
              await provider.createDraftQuote();

              if (!context.mounted) return;

              _showProviderMessage(context, provider);
            },
          ),
        ],
      ),
    );
  }

  void _showProviderMessage(BuildContext context, SteamTrapProvider provider) {
    final message = provider.sendMessage?.trim();

    if (message == null || message.isEmpty) return;

    AppToast.show(
      context,
      message: message,
      type: provider.sendMessageType ?? AppToastType.info,
      duration: const Duration(seconds: 4),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final bool outlined;
  final String label;
  final String? loadingLabel;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.enabled,
    required this.loading,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loadingLabel,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          const SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: Colors.white,
            ),
          )
        else
          Icon(icon, size: 19),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            loading ? loadingLabel ?? label : label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton(
          onPressed: enabled && !loading ? onPressed : null,
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: enabled && !loading ? onPressed : null,
        child: child,
      ),
    );
  }
}

class _ValidationBox extends StatelessWidget {
  final String message;

  const _ValidationBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return _StatusBox(
      message: message,
      title: 'Validación requerida',
      icon: Icons.warning_amber_rounded,
      color: const Color(0xfff59e0b),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String message;
  final AppToastType type;

  const _MessageBox({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle(type);

    return _StatusBox(
      message: message,
      title: style.title,
      icon: style.icon,
      color: style.color,
    );
  }

  _StatusStyle _statusStyle(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return const _StatusStyle(
          title: 'Proceso completado',
          icon: Icons.check_circle_outline_rounded,
          color: Color(0xff22c55e),
        );
      case AppToastType.error:
        return const _StatusStyle(
          title: 'No se pudo completar',
          icon: Icons.error_outline_rounded,
          color: Color(0xffef4444),
        );
      case AppToastType.warning:
        return const _StatusStyle(
          title: 'Requiere revisión',
          icon: Icons.warning_amber_rounded,
          color: Color(0xfff59e0b),
        );
      case AppToastType.info:
        return const _StatusStyle(
          title: 'Información',
          icon: Icons.info_outline_rounded,
          color: Color(0xff3b82f6),
        );
    }
  }
}

class _StatusBox extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color color;

  const _StatusBox({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ResultBox({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 86),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xff273040),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 18),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 145),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 17),
          const SizedBox(width: 7),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoMetric {
  final String label;
  final String value;
  final IconData icon;

  const _InfoMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _StatusStyle {
  final String title;
  final IconData icon;
  final Color color;

  const _StatusStyle({
    required this.title,
    required this.icon,
    required this.color,
  });
}
