import 'dart:convert';

import 'package:dio/dio.dart';
import 'api_exception.dart';

class ApiHandler {
  static Future<Map<String, dynamic>> run(
    Future<Response> Function() request,
  ) async {
    try {
      final response = await request();

      final responseData = _toMap(response.data);
      final success = responseData['success'] == true;

      if (!success) {
        throw _exceptionFromResponseData(
          responseData,
          response.statusCode ?? 500,
        );
      }

      return responseData;
    } on DioException catch (e) {
      throw _exceptionFromDio(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(
        message: e.toString().replaceFirst('Exception: ', ''),
        status: 500,
      );
    }
  }

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is String) {
      try {
        final decoded = jsonDecode(data);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return {
          'success': false,
          'message': data.trim().isNotEmpty
              ? data
              : 'Respuesta inválida del servidor',
          'data': data,
        };
      }
    }

    return {
      'success': false,
      'message': 'Respuesta inválida del servidor',
      'data': data,
    };
  }

  static ApiException _exceptionFromDio(DioException e) {
    final response = e.response;
    final status = response?.statusCode ?? 0;

    if (response?.data is Map || response?.data is String) {
      final responseData = _toMap(response?.data);

      return _exceptionFromResponseData(responseData, status);
    }

    return ApiException(
      message: _networkMessage(e),
      status: status,
      data: response?.data,
    );
  }

  static ApiException _exceptionFromResponseData(
    Map<String, dynamic> responseData,
    int fallbackStatus,
  ) {
    final status = _parseStatus(responseData['status']) ?? fallbackStatus;

    return ApiException(
      message: _extractMessage(responseData),
      status: status,
      data: responseData['data'],
      errors: responseData['errors'],
    );
  }

  static int? _parseStatus(dynamic status) {
    if (status == null) return null;

    if (status is int) return status;

    return int.tryParse(status.toString());
  }

  static String _extractMessage(Map<String, dynamic> responseData) {
    final validationMessage = _firstValidationError(responseData['errors']);

    if (validationMessage != null && validationMessage.trim().isNotEmpty) {
      return validationMessage;
    }

    final message = responseData['message'];

    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString();
    }

    final error = responseData['error'];

    if (error != null && error.toString().trim().isNotEmpty) {
      return error.toString();
    }

    return 'No se pudo completar la operación.';
  }

  static String? _firstValidationError(dynamic errors) {
    if (errors is! Map) return null;

    for (final value in errors.values) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }

      if (value != null) {
        return value.toString();
      }
    }

    return null;
  }

  static String _networkMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Tiempo de espera agotado. Verifica tu conexión.';
    }

    if (e.type == DioExceptionType.connectionError) {
      return 'No se pudo conectar con el servidor.';
    }

    if (e.type == DioExceptionType.cancel) {
      return 'Solicitud cancelada.';
    }

    return 'Error de red: ${e.message ?? 'No se pudo procesar la solicitud.'}';
  }
}
