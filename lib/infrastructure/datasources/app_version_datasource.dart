import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/api_exception.dart';
import 'package:tuvalapp/config/http/api_handler.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/config/http/endpoints/app_version_endpoints.dart';
import 'package:tuvalapp/domain/entities/app_version_info.dart';

class AppVersionDatasource {
  final Dio _dio = DioClient.instance;

  Future<AppVersionInfo> getLatestVersion({String platform = 'android'}) async {
    final responseData = await ApiHandler.run(() {
      return _dio.get(
        AppVersionEndpoints.latest,
        queryParameters: {'platform': platform},
        options: Options(extra: {'requiresAuth': false}),
      );
    });
    final versionData = responseData['data'];
    if (versionData is! Map) {
      throw const ApiException(
        message: 'No se encontró información de versión',
        status: 404,
      );
    }
    return AppVersionInfo.fromJson(Map<String, dynamic>.from(versionData));
  }
}
