import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class DeliveryNoteQrScreen extends StatefulWidget {
  const DeliveryNoteQrScreen({super.key});

  @override
  State<DeliveryNoteQrScreen> createState() => _DeliveryNoteQrScreenState();
}

class _DeliveryNoteQrScreenState extends State<DeliveryNoteQrScreen> {
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _completed = false;

  void _onDetect(BarcodeCapture capture) {
    if (_completed || !mounted) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value == null || value.trim().isEmpty) continue;
      _completed = true;
      Navigator.of(context).pop(value);
      return;
    }
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Leer QR')),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Apunte la cámara al código QR de la guía.'),
        ),
        Expanded(
          child: MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No se pudo acceder a la cámara. Revise el permiso de cámara '
                  'en los ajustes del dispositivo y vuelva a abrir el lector.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
