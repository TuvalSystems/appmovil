class SteamTrapQuoteResponse {
  final String message;
  const SteamTrapQuoteResponse({required this.message});

  factory SteamTrapQuoteResponse.fromJson(Map<String, dynamic> json) =>
      SteamTrapQuoteResponse(
        message:
            json['message']?.toString() ??
            'Cotización borrador creada correctamente.',
      );
}
