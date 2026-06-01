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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff07101f),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recomendación',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(
            provider.recommendedTrap,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presión: ${provider.fmt(provider.pressurePsig, 2)} PSIG',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 8),
          if (provider.isHeatingProcess) ...[
            Text(
              'hfg: ${provider.fmt(provider.hfg, 1)} kJ/kg',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'Método: ${provider.calculationMethod}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          if (provider.isHeatingProcess) ...[
            const SizedBox(height: 8),
            Text(
              'Q requerido: ${provider.fmt(provider.calorRequeridoKj, 2)} kJ',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
          const SizedBox(height: 14),
          if (validationMessage != null)
            _ValidationBox(message: validationMessage)
          else
            Row(
              children: [
                Expanded(
                  child: _ResultBox(
                    title: 'Carga estimada',
                    value: '${provider.fmt(provider.cargaEstimada, 2)} kg/h',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ResultBox(
                    title: 'Referencia con FS=1.5',
                    value: '${provider.fmt(provider.cargaConFs, 2)} kg/h',
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Text(
            provider.isHeatingProcess
                ? 'Cálculo por energía: 60 × ρ × V × Cp × ΔT / (hfg × t min).'
                : 'Cálculo por drenaje: carga conocida o 0.15 × BHP × 15.65.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff111a2b),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acciones',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canExecuteActions
                        ? () async {
                            await provider.generateSizingPdf();
                            if (!context.mounted) return;
                            final message = provider.sendMessage;
                            if (message != null && message.trim().isNotEmpty) {
                              AppToast.auto(context, message);
                            }
                          }
                        : null,
                    icon: provider.isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(
                      provider.isSending
                          ? 'Generando PDF...'
                          : 'Generar PDF técnico',
                    ),
                  ),
                ),

                if (provider.generatedPdfUrl != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isBusy
                          ? null
                          : () => _openGeneratedPdf(context, provider),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Abrir PDF generado'),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canExecuteActions
                        ? () async {
                            await provider.createDraftQuote();
                            if (!context.mounted) return;
                            final message = provider.sendMessage;
                            if (message != null && message.trim().isNotEmpty) {
                              AppToast.auto(context, message);
                            }
                          }
                        : null,
                    icon: provider.isCreateQuote
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.request_quote_outlined),
                    label: Text(
                      provider.isCreateQuote
                          ? 'Creando cotización...'
                          : 'Crear cotización borrador',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (provider.sendMessage != null &&
              provider.sendMessage!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _MessageBox(message: provider.sendMessage!),
          ],
        ],
      ),
    );
  }

  Future<void> _openGeneratedPdf(
    BuildContext context,
    SteamTrapProvider provider,
  ) async {
    final url = provider.generatedPdfUrl;

    if (url == null || url.isEmpty) {
      AppToast.error(context, 'No se encontró la URL del PDF generado.');
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null) {
      AppToast.error(context, 'La URL del PDF no es válida.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && context.mounted) {
      AppToast.error(context, 'No se pudo abrir el PDF.');
    }
  }
}

class _ValidationBox extends StatelessWidget {
  final String message;

  const _ValidationBox({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.45)),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.35),
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String title;
  final String value;

  const _ResultBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff273040),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String message;

  const _MessageBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final lowerMessage = message.toLowerCase();

    final isError =
        lowerMessage.contains('error') ||
        lowerMessage.contains('no se pudo') ||
        lowerMessage.contains('seleccione') ||
        lowerMessage.contains('válida') ||
        lowerMessage.contains('requiere revisión');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.withValues(alpha: 0.16)
            : Colors.green.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? Colors.red.withValues(alpha: 0.45)
              : Colors.green.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
