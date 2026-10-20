import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:tuvalapp/infrastructure/datasources/delivery_notes_datasource.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note_files.dart';
import 'package:tuvalapp/presentation/screens/inventory/delivery_note/widgets/signature_pad.dart';

class DeliveryNoteFilesScreen extends StatefulWidget {
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
  State<DeliveryNoteFilesScreen> createState() =>
      _DeliveryNoteFilesScreenState();
}

class _DeliveryNoteFilesScreenState extends State<DeliveryNoteFilesScreen> {
  DeliveryNoteFiles _files = const DeliveryNoteFiles();
  List<PendingDeliveryNoteFile> _pending = [];
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _load();
      if (mounted && widget.openSignature && _error == null) {
        await _sign();
      }
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final files = await widget.datasource.files(widget.guide);
      if (mounted) setState(() => _files = files);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _message(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _sign() async {
    final saved = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GuideSignatureDialog(
        onSave: (bytes, signer) async {
          setState(() => _busy = true);
          try {
            final files = await widget.datasource.saveSignature(
              widget.guide,
              bytes,
              signer: signer,
            );
            if (mounted) setState(() => _files = files);
          } finally {
            if (mounted) setState(() => _busy = false);
          }
        },
      ),
    );
    if (saved == true) _message('Firma guardada.');
  }

  Future<void> _pick() async {
    setState(() => _busy = true);
    try {
      final selected = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
      );
      if (selected.isEmpty) return;
      if (selected.length > 10) {
        throw StateError('Seleccione hasta 10 archivos.');
      }
      final pending = <PendingDeliveryNoteFile>[];
      for (final file in selected) {
        final size = await file.length();
        if (size == null || size == 0 || size > 10 * 1024 * 1024) {
          throw StateError(
            '${file.name}: el archivo debe pesar entre 1 byte y 10 MB.',
          );
        }
        final extension = file.name.split('.').last.toLowerCase();
        final mime = {
          'pdf': 'application/pdf',
          'png': 'image/png',
          'jpg': 'image/jpeg',
          'jpeg': 'image/jpeg',
          'webp': 'image/webp',
        }[extension];
        if (mime == null) throw StateError('Formato de archivo no permitido.');
        pending.add(
          PendingDeliveryNoteFile(file.name, await file.readAsBytes(), mime),
        );
      }
      if (!mounted) return;
      setState(() => _pending = pending);
      await _upload();
    } catch (e) {
      _message(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _upload() async {
    setState(() => _busy = true);
    try {
      final files = await widget.datasource.saveDocuments(
        widget.guide,
        _pending,
      );
      if (mounted) {
        setState(() {
          _files = files;
          _pending = [];
        });
      }
      _message('Documentos guardados.');
    } catch (e) {
      _message(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(DeliveryNoteAttachment file) async {
    setState(() => _busy = true);
    try {
      final bytes = await widget.datasource.download(widget.guide, file.id);
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
      _message(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(title: const Text('Firma y documentos')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _busy ? () async {} : _load,
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
                  if (_error != null) ...[
                    Text(_error!),
                    TextButton(
                      onPressed: _load,
                      child: const Text('Reintentar'),
                    ),
                  ],
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _busy || _error != null ? null : _sign,
                        icon: const Icon(Icons.draw_outlined),
                        label: Text(
                          _files.signatures.isEmpty
                              ? 'Firmar'
                              : 'Cambiar firma',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            _busy || _error != null || _pending.isNotEmpty
                            ? null
                            : _pick,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Adjuntar documentos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('PDF, JPG, PNG o WEBP · Hasta 10 MB por archivo.'),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: LinearProgressIndicator(),
                    ),
                  if (_pending.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Pendientes de guardar: ${_pending.map((file) => file.name).join(', ')}',
                    ),
                    TextButton(
                      onPressed: _busy ? null : _upload,
                      child: const Text('Reintentar carga'),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() => _pending = []),
                      child: const Text('Quitar selección'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Firma de recepción',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_files.signatures.isEmpty)
                    const Text('Esta guía todavía no tiene firmas.'),
                  ..._files.signatures.map((file) => _attachment(file, true)),
                  const SizedBox(height: 24),
                  Text(
                    'Documentos (${_files.documents.length})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (_files.documents.isEmpty)
                    const Text('No hay documentos adjuntos.'),
                  ..._files.documents.map((file) => _attachment(file, false)),
                ],
              ),
            ),
    ),
  );

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
