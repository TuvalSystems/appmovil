class DeliveryNote {
  final int id;
  final String number;
  final String type;
  final DateTime? departureAt;

  const DeliveryNote({
    required this.id,
    required this.number,
    required this.type,
    this.departureAt,
  });

  String get departureDateLabel {
    final date = departureAt;
    if (date == null) return 'Sin fecha de salida';
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  factory DeliveryNote.fromJson(Map<String, dynamic> json) => DeliveryNote(
    id: int.parse(json['id'].toString()),
    number: json['numero_guia']?.toString() ?? '',
    type: json['tipo'].toString(),
    departureAt: DateTime.tryParse(json['fecha_salida']?.toString() ?? ''),
  );
}

class DeliveryNoteOption {
  final String id;
  final String label;

  const DeliveryNoteOption(this.id, this.label);
}

class DeliveryNotePage {
  final List<DeliveryNote> items;
  final int page;
  final int lastPage;
  final int total;

  const DeliveryNotePage({
    required this.items,
    required this.page,
    required this.lastPage,
    required this.total,
  });

  factory DeliveryNotePage.fromJson(Map<String, dynamic> json) =>
      DeliveryNotePage(
        items: (json['data'] as List)
            .map(
              (item) =>
                  DeliveryNote.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList(),
        page: int.parse(json['current_page'].toString()),
        lastPage: int.parse(json['last_page'].toString()),
        total: int.parse(json['total'].toString()),
      );
}

class DeliveryNoteCustomer {
  final int id;
  final String name;
  final String identification;

  const DeliveryNoteCustomer(this.id, this.name, this.identification);

  factory DeliveryNoteCustomer.fromJson(Map<String, dynamic> json) =>
      DeliveryNoteCustomer(
        int.parse(json['id'].toString()),
        json['CLI_RAZON_SOCIAL']?.toString().trim() ?? '',
        json['CLI_RUC']?.toString().trim() ?? '',
      );
}
