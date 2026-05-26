class ApiException implements Exception {
  final String message;
  final int status;
  final dynamic data;
  final dynamic errors;

  const ApiException({
    required this.message,
    required this.status,
    this.data,
    this.errors,
  });

  bool get isServerError => status >= 500;
  bool get isClientError => status >= 400 && status < 500;
  bool get isWarning => status >= 400 && status < 500;

  @override
  String toString() => message;
}