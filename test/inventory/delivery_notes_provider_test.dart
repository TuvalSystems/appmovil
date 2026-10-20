import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvalapp/infrastructure/datasources/delivery_notes_datasource.dart';
import 'package:tuvalapp/infrastructure/models/inventory/delivery_note.dart';
import 'package:tuvalapp/presentation/screens/inventory/delivery_note/providers/delivery_notes_provider.dart';

class _FakeDatasource extends DeliveryNotesDatasource {
  final List<Map<String, Object?>> calls = [];
  Future<DeliveryNotePage> Function(String, int)? respond;

  @override
  Future<List<DeliveryNoteOption>> types() async => const [
    DeliveryNoteOption('despacho', 'Despacho'),
    DeliveryNoteOption('reserva', 'Reserva'),
    DeliveryNoteOption('transferencia', 'Transferencia'),
    DeliveryNoteOption('reposicion', 'Reposición'),
  ];
  @override
  Future<List<DeliveryNoteOption>> warehouses() async => const [
    DeliveryNoteOption('7', 'Bodega 7'),
  ];
  @override
  Future<DeliveryNotePage> list({
    required String type,
    required int pointSaleId,
    int? originWarehouseId,
    int? customerId,
    int page = 1,
  }) {
    calls.add({
      'type': type,
      'pointSale': pointSaleId,
      'originWarehouse': originWarehouseId,
      'customer': customerId,
      'page': page,
    });
    return respond?.call(type, page) ?? Future.value(_page(type, page));
  }
}

DeliveryNotePage _page(String type, int page) => DeliveryNotePage(
  items: [DeliveryNote(id: page, number: 'GUIA-$page', type: type)],
  page: page,
  lastPage: 2,
  total: 2,
);

void main() {
  test('parses and formats the common departure date returned by Laravel', () {
    final guide = DeliveryNote.fromJson({
      'id': 1,
      'numero_guia': '001-001-000000001',
      'tipo': 'reserva',
      'fecha_salida': '2026-10-19 09:00:00',
    });
    expect(guide.departureDateLabel, '19/10/2026');
    expect(guide.id, 1);
    expect(
      const DeliveryNote(
        id: 2,
        number: '2',
        type: 'despacho',
      ).departureDateLabel,
      'Sin fecha de salida',
    );
  });

  test(
    'changing the active point of sale restarts the query and clearing it removes old data',
    () async {
      final source = _FakeDatasource();
      final state = DeliveryNotesProvider(datasource: source);
      addTearDown(state.dispose);
      await state.initialize(3);
      await state.loadMore();
      await state.changePointSale(4);
      expect(source.calls.last['pointSale'], 4);
      expect(source.calls.last['page'], 1);
      expect(state.items.length, 1);
      final calls = source.calls.length;
      await state.changePointSale(null);
      expect(source.calls.length, calls);
      expect(state.items, isEmpty);
      expect(state.ready, false);
    },
  );

  test('reads the nested Laravel pagination payload', () {
    final response = DeliveryNotePage.fromJson({
      'data': [
        {'id': '42', 'numero_guia': '001-001-000000042', 'tipo': 'reserva'},
      ],
      'current_page': 1,
      'last_page': 2,
      'total': 21,
    });
    expect(response.items.single.id, 42);
    expect(response.items.single.number, '001-001-000000042');
    expect(response.total, 21);
  });

  test('loads successive pages and stops at the final page', () async {
    final source = _FakeDatasource();
    final state = DeliveryNotesProvider(datasource: source);
    addTearDown(state.dispose);
    await state.initialize(3);
    await state.loadMore();
    await state.loadMore();
    expect(state.items.map((item) => item.id), [1, 2]);
    expect(source.calls.map((call) => call['page']), [1, 2]);
    expect(state.hasMore, false);
  });

  test(
    'uses customer only for dispatch and origin warehouse only for received guides',
    () async {
      final source = _FakeDatasource();
      final state = DeliveryNotesProvider(datasource: source);
      addTearDown(state.dispose);
      await state.initialize(3);
      await state.changeCustomer(
        const DeliveryNoteCustomer(8, 'Cliente', '123'),
      );
      expect(source.calls.last['customer'], 8);
      expect(source.calls.last['originWarehouse'], null);
      for (final type in ['reserva', 'transferencia', 'reposicion']) {
        await state.changeType(type);
        expect(state.customer, null);
        expect(state.originWarehouseId, null);
        await state.changeOriginWarehouse(7);
        expect(source.calls.last['originWarehouse'], 7);
        expect(source.calls.last['customer'], null);
        expect(source.calls.last['page'], 1);
      }
      await state.changeType('despacho');
      expect(state.originWarehouseId, null);
      expect(source.calls.last['originWarehouse'], null);
    },
  );

  test(
    'ignores an old request when filters change before it completes',
    () async {
      final source = _FakeDatasource();
      final old = Completer<DeliveryNotePage>();
      source.respond = (type, page) =>
          type == 'despacho' ? old.future : Future.value(_page(type, page));
      final state = DeliveryNotesProvider(datasource: source);
      addTearDown(state.dispose);
      final initial = state.initialize(3);
      while (source.calls.isEmpty) {
        await Future<void>.delayed(Duration.zero);
      }
      await state.changeType('reserva');
      old.complete(_page('despacho', 1));
      await initial;
      expect(state.items.single.type, 'reserva');
    },
  );

  test(
    'keeps previous rows and retries the same page after a paging failure',
    () async {
      final source = _FakeDatasource();
      final state = DeliveryNotesProvider(datasource: source);
      addTearDown(state.dispose);
      await state.initialize(3);
      source.respond = (_, _) => Future.error(Exception('Sin conexión'));
      await state.loadMore();
      expect(state.page, 1);
      expect(state.items.length, 1);
      expect(state.error, contains('Sin conexión'));
      source.respond = (type, page) async => _page(type, page);
      await state.loadMore();
      expect(state.items.length, 2);
      expect(state.error, null);
    },
  );
}
