class SignatureLocation {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime signedAt;

  SignatureLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.signedAt,
  }) {
    if (!latitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        !longitude.isFinite ||
        longitude < -180 ||
        longitude > 180 ||
        !accuracy.isFinite ||
        accuracy < 0) {
      throw ArgumentError(
        'La ubicación obtenida no es válida. Intente nuevamente.',
      );
    }
  }

  Map<String, dynamic> toFormFields() => {
    'latitud': latitude,
    'longitud': longitude,
    'precision_ubicacion': accuracy,
    'fecha_firma': signedAt.toUtc().toIso8601String(),
  };
}
