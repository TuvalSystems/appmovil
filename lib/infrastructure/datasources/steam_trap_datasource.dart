import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/config/http/endpoints/steam_trap_endpoints.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_sizing_request.dart';

class SteamTrapDatasource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> generateSizingPdf(
    SteamTrapSizingRequest request,
  ) async {
    try {
      final response = await _dio.post(
        SteamTrapEndpoints.generateSizingPdf,
        data: request.toJson(),
      );

      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data;
      }

      return {
        'success': true,
        'message': 'Dimensionamiento generado correctamente',
        'data': data,
      };
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        throw Exception(
          data['message']?.toString() ??
              'No se pudo generar el PDF de dimensionamiento',
        );
      }

      throw Exception(e.message ?? 'No se pudo generar el PDF de dimensionamiento');
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
