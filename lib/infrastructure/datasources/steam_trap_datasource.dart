import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/api_handler.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/config/http/endpoints/steam_trap_endpoints.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_sizing_request.dart';

class SteamTrapDatasource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> generateSizingPdf(
    SteamTrapSizingRequest request,
  ) async {
    final response = await ApiHandler.run(() {
      return _dio.post(
        SteamTrapEndpoints.generateSizingPdf,
        data: request.toJson(),
        options: Options(extra: {'requiresAuth': true}),
      );
    });
    return response;
  }

 
}
