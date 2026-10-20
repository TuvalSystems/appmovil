import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvalapp/infrastructure/datasources/delivery_notes_datasource.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note_files.dart';
import 'package:tuvalapp/presentation/screens/inventory/delivery_note/delivery_note_files_screen.dart';
import 'package:tuvalapp/presentation/screens/inventory/delivery_note/widgets/signature_pad.dart';

class _MediaDatasource extends DeliveryNotesDatasource {
  late Completer<Uint8List> saved;
  @override
  Future<DeliveryNoteFiles> files(DeliveryNote guide) async =>
      const DeliveryNoteFiles();
  @override
  Future<DeliveryNoteFiles> saveSignature(
    DeliveryNote guide,
    Uint8List bytes, {
    String? signer,
  }) async {
    saved.complete(bytes);
    return DeliveryNoteFiles(
      signatures: [
        DeliveryNoteAttachment(
          id: 7,
          name: 'firma-1.png',
          mimeType: 'image/png',
          size: bytes.length,
          signer: signer,
          uploaderId: 9,
          uploaderName: 'Operador de prueba',
          uploadedAt: DateTime(2026, 10, 20, 10, 30),
        ),
      ],
    );
  }
}

void main() {
  test('reads the server upload audit for signatures and documents', () {
    final file = DeliveryNoteAttachment.fromJson({
      'id': 7,
      'nombre': 'firma.png',
      'mime_type': 'image/png',
      'tamano': 200,
      'subido_por': {'id': 9, 'nombre': 'Operador', 'usuario': 'bodega.prueba'},
      'subido_en': '2026-10-20T10:30:00-05:00',
    });
    expect(file.uploaderId, 9);
    expect(file.uploaderName, 'Operador');
    expect(file.uploaderLogin, 'bodega.prueba');
    expect(file.uploadedAt!.toUtc(), DateTime.utc(2026, 10, 20, 15, 30));
  });

  testWidgets('blank signatures are rejected and drawn strokes export as PNG', (
    tester,
  ) async {
    final signature = GuideSignatureController();
    await expectLater(signature.toPng(), throwsStateError);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GuideSignaturePad(controller: signature)),
      ),
    );
    final rect = tester.getRect(find.byType(GuideSignaturePad));
    await tester.dragFrom(
      rect.center - const Offset(60, 0),
      const Offset(120, 20),
    );
    expect(signature.isEmpty, false);
    final png = await tester.runAsync(signature.toPng);
    expect(png!.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(png);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 1000);
      expect(frame.image.height, 400);
      final rgba = await frame.image.toByteData();
      expect(
        rgba!.buffer.asUint8List().where((byte) => byte < 100),
        isNotEmpty,
      );
      frame.image.dispose();
      codec.dispose();
    });
    signature.clear();
    expect(signature.isEmpty, true);
    await tester.pumpWidget(const SizedBox.shrink());
    signature.dispose();
  });

  testWidgets('guide action captures and saves the signature then lists it', (
    tester,
  ) async {
    final source = _MediaDatasource();
    await tester.pumpWidget(
      MaterialApp(
        home: DeliveryNoteFilesScreen(
          guide: const DeliveryNote(
            id: 1,
            number: '001-001-000000001',
            type: 'reserva',
          ),
          datasource: source,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Firma de recepción'), findsOneWidget);
    await tester.tap(find.text('Firmar'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Guardar firma'),
          )
          .onPressed,
      isNull,
    );
    final rect = tester.getRect(find.byType(GuideSignaturePad));
    await tester.dragFrom(
      rect.center - const Offset(30, 0),
      const Offset(60, 10),
    );
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Guardar firma'),
          )
          .onPressed,
      isNotNull,
    );
    final save = tester
        .widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Guardar firma'),
        )
        .onPressed!;
    await tester.runAsync(() async {
      source.saved = Completer<Uint8List>();
      save();
      final bytes = await source.saved.future.timeout(
        const Duration(seconds: 5),
      );
      expect(bytes.take(4), [137, 80, 78, 71]);
    });
    await tester.pumpAndSettle();
    expect(find.text('Cambiar firma'), findsOneWidget);
    expect(find.text('firma-1.png'), findsOneWidget);
    expect(find.text('Subido por: Operador de prueba'), findsOneWidget);
    expect(find.text('Fecha: 20/10/2026 10:30:00'), findsOneWidget);
    expect(find.byType(GuideSignatureDialog), findsNothing);
  });
}
