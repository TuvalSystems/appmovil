class SteamTrapCustomer {
  final int id;
  final String ruc;
  final String razonSocial;
  final String nombreCorto;
  final String ciudad;
  final String provincia;

  const SteamTrapCustomer({
    required this.id,
    required this.ruc,
    required this.razonSocial,
    required this.nombreCorto,
    required this.ciudad,
    required this.provincia,
  });

  String get displayName {
    return '$razonSocial - $ruc';
  }

  String get shortDisplayName {
    if (nombreCorto.isNotEmpty) {
      return '$nombreCorto - $ruc';
    }

    return displayName;
  }

  factory SteamTrapCustomer.fromSearchJson(Map<String, dynamic> json) {
    return SteamTrapCustomer(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      ruc: json['CLI_RUC']?.toString().trim() ?? '',
      razonSocial: json['CLI_RAZON_SOCIAL']?.toString().trim() ?? '',
      nombreCorto: json['CLI_NOMBRE_CORTO']?.toString().trim() ?? '',
      ciudad: json['CLI_CIUDAD']?.toString().trim() ?? '',
      provincia: json['CLI_PROVINCIA']?.toString().trim() ?? '',
    );
  }

  factory SteamTrapCustomer.fromJson(Map<String, dynamic> json) {
    return SteamTrapCustomer.fromSearchJson(json);
  }
}