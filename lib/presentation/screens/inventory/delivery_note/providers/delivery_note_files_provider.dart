import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:tuvalapp/infrastructure/datasources/delivery_notes_datasource.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note_files.dart';

class DeliveryNoteFilesProvider extends ChangeNotifier {
  final DeliveryNote guide;
  final DeliveryNotesDatasource datasource;

  DeliveryNoteFilesProvider({
    required this.guide,
    DeliveryNotesDatasource? datasource,
  }) : datasource = datasource ?? DeliveryNotesDatasource();

  DeliveryNoteFiles files = const DeliveryNoteFiles();
  List<PendingDeliveryNoteFile> pending = [];
  bool loading = true;
  bool busy = false;
  String? error;
  String? operationError;
  bool _disposed = false;

  Future<void> load() async {
    if (busy || _disposed) return;
    loading = true;
    error = null;
    _notify();
    try {
      final result = await datasource.files(guide);
      if (!_disposed) files = result;
    } catch (e) {
      if (!_disposed) error = e.toString();
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<T> _run<T>(Future<T> Function() operation) async {
    if (busy || loading || _disposed) {
      throw StateError('Hay una operación en curso.');
    }
    busy = true;
    operationError = null;
    _notify();
    try {
      return await operation();
    } catch (e) {
      if (!_disposed) operationError = e.toString();
      rethrow;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> saveSignature(
    Uint8List bytes,
    String signer,
    String identification,
  ) => _run(() async {
    final result = await datasource.saveSignature(
      guide,
      bytes,
      signer: signer,
      identification: identification,
    );
    if (!_disposed) files = result;
  });

  Future<void> uploadDocuments() => _run(() async {
    final result = await datasource.saveDocuments(guide, pending);
    if (_disposed) return;
    files = result;
    pending = [];
  });

  Future<Uint8List> download(int mediaId) =>
      _run(() => datasource.download(guide, mediaId));

  void clearPending() {
    if (busy) return;
    pending = [];
    _notify();
  }

  Future<bool> pickDocuments() async {
    if (busy || loading || _disposed) return false;
    busy = true;
    operationError = null;
    _notify();
    try {
      final selected = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'webp'],
      );
      if (selected.isEmpty) return false;
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
      if (_disposed) return false;
      this.pending = pending;
      final result = await datasource.saveDocuments(guide, pending);
      if (_disposed) return false;
      files = result;
      this.pending = [];
      return true;
    } catch (e) {
      operationError = e.toString();
      rethrow;
    } finally {
      busy = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
