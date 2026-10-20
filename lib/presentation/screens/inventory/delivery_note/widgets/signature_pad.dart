import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GuideSignatureController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  bool get isEmpty => _strokes.isEmpty;

  void start(Offset point) {
    _strokes.add([point]);
    notifyListeners();
  }

  void update(Offset point) {
    if (_strokes.isEmpty) return;
    _strokes.last.add(point);
    notifyListeners();
  }

  void clear() {
    _strokes.clear();
    notifyListeners();
  }

  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final ink = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in _strokes) {
      Offset pixel(Offset point) =>
          Offset(point.dx * size.width, point.dy * size.height);
      if (stroke.length == 1) {
        canvas.drawCircle(
          pixel(stroke.first),
          1.5,
          Paint()..color = Colors.black,
        );
      } else {
        final path = Path()
          ..moveTo(pixel(stroke.first).dx, pixel(stroke.first).dy);
        for (final point in stroke.skip(1)) {
          path.lineTo(pixel(point).dx, pixel(point).dy);
        }
        canvas.drawPath(path, ink);
      }
    }
  }

  Future<Uint8List> toPng() async {
    if (isEmpty) throw StateError('Dibuje su firma antes de guardar.');
    final recorder = ui.PictureRecorder();
    paint(Canvas(recorder), const Size(1000, 400));
    final picture = recorder.endRecording();
    final image = await picture.toImage(1000, 400);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw StateError('No se pudo generar la firma.');
      return data.buffer.asUint8List();
    } finally {
      image.dispose();
      picture.dispose();
    }
  }
}

class GuideSignaturePad extends StatelessWidget {
  final GuideSignatureController controller;
  const GuideSignaturePad({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 2.5,
    child: DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, bounds) {
            Offset normalize(Offset point) => Offset(
              (point.dx / bounds.maxWidth).clamp(0.0, 1.0),
              (point.dy / bounds.maxHeight).clamp(0.0, 1.0),
            );
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: (event) =>
                  controller.start(normalize(event.localPosition)),
              onPanUpdate: (event) =>
                  controller.update(normalize(event.localPosition)),
              onTapDown: (event) =>
                  controller.start(normalize(event.localPosition)),
              child: CustomPaint(
                painter: _SignaturePainter(controller),
                size: Size.infinite,
              ),
            );
          },
        ),
      ),
    ),
  );
}

class _SignaturePainter extends CustomPainter {
  final GuideSignatureController controller;
  _SignaturePainter(this.controller) : super(repaint: controller);
  @override
  void paint(Canvas canvas, Size size) => controller.paint(canvas, size);
  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) =>
      oldDelegate.controller != controller;
}

class GuideSignatureDialog extends StatefulWidget {
  final Future<void> Function(Uint8List bytes, String? signer) onSave;
  const GuideSignatureDialog({super.key, required this.onSave});
  @override
  State<GuideSignatureDialog> createState() => _GuideSignatureDialogState();
}

class _GuideSignatureDialogState extends State<GuideSignatureDialog> {
  final _signature = GuideSignatureController();
  final _name = TextEditingController();
  bool _saving = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final bytes = await _signature.toPng();
      await widget.onSave(
        bytes,
        _name.text.trim().isEmpty ? null : _name.text.trim(),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Dibuje su firma en el recuadro.'),
              const SizedBox(height: 12),
              IgnorePointer(
                ignoring: _saving,
                child: GuideSignaturePad(controller: _signature),
              ),
              TextButton(
                onPressed: _saving ? null : _signature.clear,
                child: const Text('Limpiar firma'),
              ),
              TextField(
                controller: _name,
                enabled: !_saving,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Nombre de quien firma (opcional)',
                ),
              ),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (_saving) const LinearProgressIndicator(),
            ],
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
