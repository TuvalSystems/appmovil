import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:tuvalapp/config/http/api_exception.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note_files.dart';
import 'package:dio/dio.dart';
import 'package:tuvalapp/config/http/api_handler.dart';
import 'package:tuvalapp/config/http/dio_client.dart';
import 'package:tuvalapp/config/http/endpoints/inventory_endpoints.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note.dart';

class DeliveryNotesDatasource {
  Future<List<DeliveryNoteOption>> types() async {
    final response = await _get(InventoryEndpoints.deliveryNoteTypes);
    return (response['data'] as List)
        .map(
          (item) => DeliveryNoteOption(
            item['id'].toString(),
            item['nombre'].toString(),
          ),
        )
        .toList();
  }

  Future<List<DeliveryNoteOption>> warehouses() async {
    final response = await _get(InventoryEndpoints.warehouses);
    return (response['data'] as List)
        .map(
          (item) => DeliveryNoteOption(
            item['id'].toString(),
            item['bodega'].toString(),
          ),
        )
        .toList();
  }

  Future<DeliveryNotePage> list({
    required String type,
    required int pointSaleId,
    int? originWarehouseId,
    int? customerId,
    int page = 1,
  }) async {
    final response = await _get(InventoryEndpoints.deliveryNotes, {
      'tipo': type,
      'punto_venta_id': pointSaleId,
      'page': page,
      'per_page': 20,
      if (type != 'despacho' && originWarehouseId != null)
        'bodega_origen_id': originWarehouseId,
      if (type == 'despacho' && customerId != null) 'cliente_id': customerId,
    });
    return DeliveryNotePage.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<DeliveryNote> resolveQr(String code) async {
    final response = await ApiHandler.run(
      () => DioClient.instance.post(
        '${InventoryEndpoints.deliveryNotes}/resolver-qr',
        data: {'codigo': code.trim()},
        options: Options(extra: {'requiresAuth': true}),
      ),
    );
    final data = Map<String, dynamic>.from(response['data'] as Map);
    if (data['accion'] != 'firmar_guia') {
      throw StateError('El QR no corresponde a una guía para firmar.');
    }
    return DeliveryNote.fromJson({...data, 'id': data['guia_id']});
  }
  String _guidePath(DeliveryNote guide) =>
      '${InventoryEndpoints.deliveryNotes}/${guide.type}/${guide.id}';

  Future<DeliveryNoteFiles> files(DeliveryNote guide) async {
    final response = await _get('${_guidePath(guide)}/archivos');
    return DeliveryNoteFiles.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<DeliveryNoteFiles> saveSignature(
    DeliveryNote guide,
    Uint8List bytes, {
    String? signer,
  }) => _upload(
    '${_guidePath(guide)}/firma',
    FormData.fromMap({
      'firma': MultipartFile.fromBytes(
        bytes,
        filename: 'firma-${guide.id}.png',
        contentType: MediaType('image', 'png'),
      ),
      'nombre_firmante': ?signer,
    }),
  );

  Future<DeliveryNoteFiles> saveDocuments(
    DeliveryNote guide,
    List<PendingDeliveryNoteFile> files,
  ) => _upload(
    '${_guidePath(guide)}/documentos',
    FormData.fromMap({
      'documentos[]': files
          .map(
            (file) => MultipartFile.fromBytes(
              file.bytes,
              filename: file.name,
              contentType: MediaType.parse(file.mimeType),
            ),
          )
          .toList(),
    }),
  );

  Future<DeliveryNoteFiles> _upload(String path, FormData data) async {
    final response = await ApiHandler.run(
      () => DioClient.instance.post(
        path,
        data: data,
        options: Options(
          contentType: 'multipart/form-data',
          extra: {'requiresAuth': true},
        ),
      ),
    );
    return DeliveryNoteFiles.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<Uint8List> download(DeliveryNote guide, int mediaId) async {
    try {
      final response = await DioClient.instance.get<List<int>>(
        '${_guidePath(guide)}/archivos/$mediaId',
        options: Options(
          responseType: ResponseType.bytes,
          extra: {'requiresAuth': true},
        ),
      );
      return Uint8List.fromList(response.data!);
    } on DioException catch (e) {
      throw ApiException(
        message: 'No se pudo obtener el archivo. Intente nuevamente.',
        status: e.response?.statusCode ?? 0,
      );
    }
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, dynamic>? query,
  ]) => ApiHandler.run(
    () => DioClient.instance.get(
      path,
      queryParameters: query,
      options: Options(extra: {'requiresAuth': true}),
    ),
  );
}
