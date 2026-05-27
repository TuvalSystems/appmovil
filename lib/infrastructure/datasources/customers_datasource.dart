import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/api_handler.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/config/http/endpoints/customers_endpoints.dart';

class CustomersDatasource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> searchCustomers(String search) async {
    final response = await ApiHandler.run(() {
      return _dio.post(
        CustomersEndpoints.searchClients,
        data: {"search": search, 'tipo': 'proceso'},
        options: Options(extra: {'requiresAuth': true}),
      );
    });
    return Map<String, dynamic>.from(response);
  }
  
}
