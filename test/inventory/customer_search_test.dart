import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuvalapp/infrastructure/datasources/customers_datasource.dart';
import 'package:tuvalapp/infrastructure/models/steam_traps/steam_trap_customer.dart';
import 'package:tuvalapp/presentation/shared/controllers/customer_search_controller.dart';
import 'package:tuvalapp/presentation/shared/widgets/customer_search_card.dart';
import 'package:tuvalapp/presentation/screens/inventory/delivery_note/providers/delivery_notes_provider.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/providers/steam_trap_provider.dart';

class _Customers extends CustomersDatasource {
  final queries = <String>[];
  Future<Map<String, dynamic>> Function(String)? respond;
  @override
  Future<Map<String, dynamic>> searchCustomers(String search) async {
    queries.add(search);
    return respond == null
        ? {
            'data': [
              {
                'id': 8,
                'CLI_RUC': '1234567890',
                'CLI_RAZON_SOCIAL': 'Cliente Tuval',
                'CLI_NOMBRE_CORTO': 'Tuval',
                'CLI_CIUDAD': 'Guayaquil',
                'CLI_PROVINCIA': 'Guayas',
              },
            ],
          }
        : await respond!(search);
  }
}

const customer = SteamTrapCustomer(
  id: 8,
  ruc: '1234567890',
  razonSocial: 'Cliente Tuval',
  nombreCorto: 'Tuval',
  ciudad: 'Guayaquil',
  provincia: 'Guayas',
);

void main() {
  testWidgets('shared search waits 450 ms and requires three characters', (
    tester,
  ) async {
    final source = _Customers();
    final search = CustomerSearchController(datasource: source);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomerSearchCard(
            controller: search,
            description: 'Filtrar despachos',
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'tu');
    await tester.pump(const Duration(milliseconds: 500));
    expect(source.queries, isEmpty);
    expect(
      find.text('Ingrese al menos 3 caracteres para buscar.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextField), 'tuval');
    await tester.pump(const Duration(milliseconds: 449));
    expect(source.queries, isEmpty);
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(source.queries, ['tuval']);
    expect(find.text('Cliente Tuval'), findsOneWidget);
    await tester.tap(find.text('Cliente Tuval'));
    await tester.pumpAndSettle();
    expect(search.selectedCustomer?.id, 8);
    expect(search.customerSearchController.text, 'Tuval - 1234567890');
    expect(find.text('Cliente seleccionado'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close).last);
    await tester.pumpAndSettle();
    expect(search.selectedCustomer, isNull);
    expect(search.customerSearchController.text, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    search.dispose();
  });

  test('an old request cannot replace newer search results', () async {
    final source = _Customers();
    final old = Completer<Map<String, dynamic>>();
    source.respond = (query) =>
        query == 'anterior' ? old.future : Future.value({'data': []});
    final search = CustomerSearchController(datasource: source);
    addTearDown(search.dispose);
    final request = search.searchCustomers('anterior');
    await search.searchCustomers('nuevo');
    old.complete({
      'data': [
        {'id': 8, 'CLI_RUC': '123', 'CLI_RAZON_SOCIAL': 'Anterior'},
      ],
    });
    await request;
    expect(search.customerResults, isEmpty);
    expect(search.customerSearchMessage, 'No se encontraron clientes.');
  });

  test(
    'shared selection applies and clears the delivery note customer filter',
    () {
      final notes = DeliveryNotesProvider();
      addTearDown(notes.dispose);
      notes.customerSearch.selectCustomer(customer);
      expect(notes.customer?.id, 8);
      expect(notes.customer?.name, 'Cliente Tuval');
      notes.customerSearch.clearSelectedCustomer();
      expect(notes.customer, isNull);
    },
  );

  test(
    'steam traps still use the same selected customer and clear generated results',
    () {
      final steam = SteamTrapProvider();
      addTearDown(steam.dispose);
      steam.generatedPdfUrl = 'documento.pdf';
      steam.customerSearch.selectCustomer(customer);
      expect(steam.selectedCustomer?.id, 8);
      expect(steam.generatedPdfUrl, isNull);
      steam.customerSearch.clearSelectedCustomer();
      expect(steam.selectedCustomer, isNull);
    },
  );
}
