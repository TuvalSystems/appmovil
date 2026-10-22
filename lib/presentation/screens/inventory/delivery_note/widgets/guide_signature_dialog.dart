import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'signature_pad.dart';

class GuideSignatureDialog extends StatefulWidget {
  final Future<void> Function(
    Uint8List bytes,
    String signer,
    String identification,
  )
  onSave;
  const GuideSignatureDialog({super.key, required this.onSave});
  @override
  State<GuideSignatureDialog> createState() => _GuideSignatureDialogState();
}

class _GuideSignatureDialogState extends State<GuideSignatureDialog> {
  final _signature = GuideSignatureController();
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _identification = TextEditingController();
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final bytes = await _signature.toPng();
      await widget.onSave(
        bytes,
        _name.text.trim(),
        _identification.text.trim(),
      );
      if (mounted) {
        setState(() => _saving = false);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _signature.dispose();
    _name.dispose();
    _identification.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: AlertDialog(
      title: const Text('Firmar guía'),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Dibuje su firma en el recuadro.'),
                const SizedBox(height: 8),
                const Text(
                  'Al guardar se registrarán su ubicación, la precisión en metros y la fecha y hora. Active la ubicación y permita su acceso.',
                ),
                const SizedBox(height: 12),
                IgnorePointer(
                  ignoring: _saving,
                  child: GuideSignaturePad(controller: _signature),
                ),
                TextButton(
                  onPressed: _saving ? null : _signature.clear,
                  child: const Text('Limpiar firma'),
                ),
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingrese el nombre de quien firma.'
                      : null,
                  enabled: !_saving,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de quien firma *',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _identification,
                  enabled: !_saving,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  maxLength: 30,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Ingrese el número de identificación.'
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Número de identificación *',
                  ),
                ),
                if (_error != null)
                  Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                if (_saving) ...[
                  const Text('Obteniendo ubicación y guardando firma…'),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ListenableBuilder(
          listenable: _signature,
          builder: (_, _) => FilledButton(
            onPressed: _saving || _signature.isEmpty ? null : _save,
            child: const Text('Guardar firma'),
          ),
        ),
      ],
    ),
  );
}
