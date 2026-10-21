class SteamTrapSizingResponse {
  final String? pdfUrl;
  final String message;
  const SteamTrapSizingResponse({this.pdfUrl, required this.message});

  factory SteamTrapSizingResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SteamTrapSizingResponse(
      pdfUrl: data is Map ? data['pdfUrl']?.toString() : null,
      message: json['message']?.toString() ?? 'PDF generado correctamente.',
    );
  }
}
