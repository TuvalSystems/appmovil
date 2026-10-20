import 'dart:typed_data';

class DeliveryNoteAttachment {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final String? signer;
  final int? uploaderId;
  final String? uploaderName;
  final String? uploaderLogin;
  final DateTime? uploadedAt;

  const DeliveryNoteAttachment({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.signer,
    this.uploaderId,
    this.uploaderName,
    this.uploaderLogin,
    this.uploadedAt,
  });

  factory DeliveryNoteAttachment.fromJson(Map<String, dynamic> json) =>
      DeliveryNoteAttachment(
        id: int.parse(json['id'].toString()),
        name: json['nombre'].toString(),
        mimeType: json['mime_type'].toString(),
        size: int.parse(json['tamano'].toString()),
        signer: json['nombre_firmante']?.toString(),
        uploaderId: int.tryParse(json['subido_por']?['id']?.toString() ?? ''),
        uploaderName: json['subido_por']?['nombre']?.toString(),
        uploaderLogin: json['subido_por']?['usuario']?.toString(),
        uploadedAt: DateTime.tryParse(
          (json['subido_en'] ?? json['creado_en'])?.toString() ?? '',
        ),
      );
}

class DeliveryNoteFiles {
  final List<DeliveryNoteAttachment> signatures;
  final List<DeliveryNoteAttachment> documents;
  const DeliveryNoteFiles({
    this.signatures = const [],
    this.documents = const [],
  });

  factory DeliveryNoteFiles.fromJson(Map<String, dynamic> json) {
    List<DeliveryNoteAttachment> parse(String key) => (json[key] as List? ?? [])
        .map(
          (item) => DeliveryNoteAttachment.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
    return DeliveryNoteFiles(
      signatures: parse('firmas'),
      documents: parse('documentos'),
    );
  }
}

class PendingDeliveryNoteFile {
  final String name;
  final Uint8List bytes;
  final String mimeType;
  const PendingDeliveryNoteFile(this.name, this.bytes, this.mimeType);
}
