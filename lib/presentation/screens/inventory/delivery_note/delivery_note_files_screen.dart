import 'package:tuvalapp/presentation/shared/widgets/app_toast.dart';
import 'package:tuvalapp/presentation/shared/widgets/tuval_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/delivery_note_files_provider.dart';
import 'package:tuvalapp/infrastructure/datasources/delivery_notes_datasource.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note_files.dart';
import 'package:tuvalapp/presentation/screens/inventory/delivery_note/widgets/guide_signature_dialog.dart';

class DeliveryNoteFilesScreen extends StatelessWidget {
  final DeliveryNote guide;
  final bool openSignature;
  final DeliveryNotesDatasource datasource;
  const DeliveryNoteFilesScreen({
    super.key,
    required this.guide,
    required this.datasource,
    this.openSignature = false,
  });
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) =>
        DeliveryNoteFilesProvider(guide: guide, datasource: datasource),
    child: _DeliveryNoteFilesView(guide: guide, openSignature: openSignature),
  );
}

class _DeliveryNoteFilesView extends StatefulWidget {
  final DeliveryNote guide;
  final bool openSignature;
  const _DeliveryNoteFilesView({
    required this.guide,
    required this.openSignature,
  });

  @override
  State<_DeliveryNoteFilesView> createState() => _DeliveryNoteFilesViewState();
}

class _DeliveryNoteFilesViewState extends State<_DeliveryNoteFilesView> {
  DeliveryNoteFilesProvider get _state =>
      context.read<DeliveryNoteFilesProvider>();
  bool _opening = false;
  bool get _busy => _state.busy || _opening;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _state.load();
      if (mounted && widget.openSignature && _state.error == null) {
        await _sign();
      }
    });
  }

  void _message(String message, {bool error = false}) {
    if (!mounted) return;
    if (error) {
      AppToast.error(context, message);
    } else {
      AppToast.success(context, message);
    }
  }

  Future<void> _sign() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GuideSignatureDialog(onSave: _state.saveSignature),
    );
    if (saved == true) _message('Firma guardada.');
  }

  Future<void> _pick() async {
    try {
      if (await _state.pickDocuments()) _message('Documentos guardados.');
    } catch (e) {
      _message(e.toString(), error: true);
    }
  }

  Future<void> _upload() async {
    try {
      await _state.uploadDocuments();
      _message('Documentos guardados.');
    } catch (e) {
      _message(e.toString(), error: true);
    }
  }

  Future<void> _open(DeliveryNoteAttachment file) async {
    setState(() => _opening = true);
    try {
      final bytes = await _state.download(file.id);
      if (!mounted) return;
      if (file.mimeType.startsWith('image/')) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(file.name),
            content: SizedBox(
              width: 600,
              height: 300,
              child: InteractiveViewer(child: Image.memory(bytes)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      } else {
        final saved = await FilePicker.saveFile(
          fileName: file.name,
          bytes: bytes,
        );
        if (saved != null) _message('Documento guardado en el dispositivo.');
      }
    } catch (e) {
      _message(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DeliveryNoteFilesProvider>();
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: const TuvalAppBar(
          title: 'Firma y documentos',
          showPointSale: false,
        ),
        body: _state.loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _busy ? () async {} : _state.load,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Text(
                      widget.guide.number,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Firma de recepción y documentos relacionados con esta guía.',
                    ),
                    const SizedBox(height: 16),
                    if (_state.error != null) ...[
                      Text(_state.error!),
                      TextButton(
                        onPressed: _state.load,
                        child: const Text('Reintentar'),
                      ),
                    ],
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: _busy || _state.error != null
                              ? null
                              : _sign,
                          icon: const Icon(Icons.draw_outlined),
                          label: Text(
                            _state.files.signatures.isEmpty
                                ? 'Firmar'
                                : 'Cambiar firma',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed:
                              _busy ||
                                  _state.error != null ||
                                  _state.pending.isNotEmpty
                              ? null
                              : _pick,
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Adjuntar documentos'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'PDF, JPG, PNG o WEBP · Hasta 10 MB por archivo.',
                    ),
                    if (_busy)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: LinearProgressIndicator(),
                      ),
                    if (_state.pending.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Pendientes de guardar: ${_state.pending.map((file) => file.name).join(', ')}',
                      ),
                      TextButton(
                        onPressed: _busy ? null : _upload,
                        child: const Text('Reintentar carga'),
                      ),
                      TextButton(
                        onPressed: _busy ? null : _state.clearPending,
                        child: const Text('Quitar selección'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      'Firma de recepción',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_state.files.signatures.isEmpty)
                      const Text('Esta guía todavía no tiene firmas.'),
                    ..._state.files.signatures.map(
                      (file) => _attachment(file, true),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Documentos (${_state.files.documents.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (_state.files.documents.isEmpty)
                      const Text('No hay documentos adjuntos.'),
                    ..._state.files.documents.map(
                      (file) => _attachment(file, false),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  String _auditDate(DateTime timestamp) {
    final local = timestamp.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} ${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }

  Widget _attachment(DeliveryNoteAttachment file, bool signature) => Card(
    child: ListTile(
      leading: Icon(
        signature ? Icons.draw_outlined : Icons.insert_drive_file_outlined,
      ),
      title: Text(file.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            signature && file.signer != null
                ? file.signer!
                : '${(file.size / 1024).ceil()} KB',
          ),
          if (file.uploaderName != null || file.uploaderId != null)
            Text(
              'Subido por: ${file.uploaderName ?? file.uploaderLogin ?? "Usuario ${file.uploaderId}"}',
            ),
          if (file.uploadedAt != null)
            Text('Fecha: ${_auditDate(file.uploadedAt!)}'),
        ],
      ),
      trailing: Icon(
        file.mimeType.startsWith('image/')
            ? Icons.visibility_outlined
            : Icons.download_outlined,
      ),
      onTap: _busy ? null : () => _open(file),
    ),
  );
}
