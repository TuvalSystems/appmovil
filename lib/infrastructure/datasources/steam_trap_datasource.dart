import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_sizing_response.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_quote_response.dart';
import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/api_handler.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/config/http/endpoints/steam_trap_endpoints.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_sizing_request.dart';

class SteamTrapDatasource {
  final Dio _dio;

  SteamTrapDatasource({Dio? dio}) : _dio = dio ?? DioClient.instance;

  Future<SteamTrapSizingResponse> generateSizingPdf(
    SteamTrapSizingRequest request,
  ) async {
    final response = await ApiHandler.run(() {
      return _dio.post(
        SteamTrapEndpoints.generateSizingPdf,
        data: request.toJson(),
        options: Options(extra: {'requiresAuth': true}),
      );
    });
    return SteamTrapSizingResponse.fromJson(response);
  }

  Future<SteamTrapQuoteResponse> createDraftQuote(
    SteamTrapSizingRequest request,
  ) async {
    final response = await ApiHandler.run(() {
      return _dio.post(
        SteamTrapEndpoints.createQuote,
        data: request.toJson(),
        options: Options(extra: {'requiresAuth': true}),
      );
    });
    return SteamTrapQuoteResponse.fromJson(response);
  }
}
