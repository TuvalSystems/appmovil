import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/config/http/endpoints/app_version_endpoints.dart';
import 'package:tuvalapp/domain/entities/app_version_info.dart';

class AppVersionDatasource {
  final Dio _dio = DioClient.instance;

  Future<AppVersionInfo> getLatestVersion({String platform = 'android'}) async {
    try {
      final response = await _dio.get(
        AppVersionEndpoints.latest,
        queryParameters: {'platform': platform},
        options: Options(extra: {'requiresAuth': false}),
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
