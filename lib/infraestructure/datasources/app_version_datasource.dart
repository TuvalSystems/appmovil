import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:tuvalapp/domain/entities/app_version_info.dart';

class AppVersionDatasource {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://tuvalapi.cosenco.ec/api',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  Future<AppVersionInfo> getLatestVersion({
    String platform = 'android',
  }) async {
    try {
      final response = await dio.get(
        '/movil/app/latest',
        queryParameters: {
          'platform': platform,
        },
      );

      final responseData = _normalizeResponseData(response.data);

      if (responseData is! Map<String, dynamic>) {
        throw Exception('Respuesta inválida del servidor');
      }

      final versionData = responseData['data'];

      if (versionData is! Map<String, dynamic>) {
        throw Exception('No se encontró información de versión');
      }

      return AppVersionInfo.fromJson(versionData);
    } on DioException catch (e) {
      throw Exception(_getDioErrorMessage(e));
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  dynamic _normalizeResponseData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is String) {
      try {
        return jsonDecode(data);
      } catch (_) {
        return data;
      }
    }

    return data;
  }

  String _getDioErrorMessage(DioException e) {
    final data = e.response?.data;

    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          'No se pudo consultar la versión disponible';
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return e.message ?? 'No se pudo consultar la versión disponible';
  }
}