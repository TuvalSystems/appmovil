import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SteamTrapProvider>();
    final validationMessage = provider.validationMessage;

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
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          if (provider.isHeatingProcess) ...[
            Text(
              'hfg: ${provider.fmt(provider.hfg, 1)} kJ/kg',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'Método: ${provider.calculationMethod}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          if (provider.isHeatingProcess) ...[
            const SizedBox(height: 8),
            Text(
              'Q requerido: ${provider.fmt(provider.calorRequeridoKj, 2)} kJ',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: provider.isSending
                  ? null
                  : provider.generateSizingPdf,
              icon: provider.isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf_outlined),
              label: Text(
                provider.isSending ? 'Generando...' : 'Generar PDF',
              ),
            ),
          ),
          if (provider.generatedPdfUrl != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openGeneratedPdf(context, provider),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir PDF generado'),
              ),
            ),
          ],
          if (provider.sendMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              provider.sendMessage!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                height: 1.35,
              ),
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
    final url = provider.generatedPdfUrl;

    if (url == null || url.isEmpty) {
      _showSnackBar(
        context,
        'No se encontró la URL del PDF generado.',
      );
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null) {
      _showSnackBar(
        context,
        'La URL del PDF no es válida.',
      );
      return;
    }

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      _showSnackBar(
        context,
        'No se pudo abrir el PDF.',
      );
    }
  }

  void _showSnackBar(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

class _ValidationBox extends StatelessWidget {
  final String message;

  const _ValidationBox({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.45),
        ),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.35,
        ),
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final String title;
  final String value;

  const _ResultBox({
    required this.title,
    required this.value,
  });

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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
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