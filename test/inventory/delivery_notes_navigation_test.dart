import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/router/app_router.dart';
import 'package:tuvalapp/infrastructure/models/menu/app_menu_model.dart';
import 'package:tuvalapp/infrastructure/services/key_value_storage_service.dart';
import 'package:tuvalapp/presentation/providers/auth_provider.dart';
import 'package:tuvalapp/presentation/providers/point_sales_provider.dart';
import 'package:tuvalapp/infrastructure/datasources/point_sales_datasource.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/side_menu.dart';
import 'package:tuvalapp/presentation/screens/inventory/delivery_note/delivery_notes_screen.dart';
import 'package:tuvalapp/presentation/shared/helpers/mobile_menu_mapper.dart';

class _MenuAuth extends AuthProvider {
  _MenuAuth() : super(keyValueStorageService: KeyValueStorageService());
  @override
  Future<void> checkAuthStatus() async {}
}

void main() {
  test(
    'exact backend route resolves to the registered delivery notes screen',
    () {
      final target = MobileMenuMapper.resolveRoute(
        'app.inventory.delivery_notes.index',
      );
      expect(target, AppRouter.deliveryNotes);
      expect(AppRouter.getRoutes().containsKey(target), isTrue);
      expect(
        MobileMenuMapper.resolveRoute('/inventory/delivery-notes'),
        isNull,
      );
    },
  );

  testWidgets('Inventory expands and its child Firma Guias navigates', (
    tester,
  ) async {
    final auth = _MenuAuth();
    auth.appMenu = AppMenu.fromJson({
      'items': [
        {
          'id': 74,
          'key': 'inventario',
          'label': 'Inventario',
          'icon': 'warehouse',
          'route': null,
          'children': [
            {
              'id': 75,
              'key': 'appinventorydelivery_notesindex',
              'label': 'Firma Guias',
              'icon': 'delivery_notes',
              'route': 'app.inventory.delivery_notes.index',
              'children': [],
            },
          ],
        },
      ],
    });
    final points = PointSalesProvider(
      pointSalesDatasource: PointSalesDatasource(),
      keyValueStorageService: KeyValueStorageService(),
    );
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<PointSalesProvider>.value(value: points),
        ],
        child: MaterialApp(
          routes: {
            AppRouter.deliveryNotes: (_) =>
                const Scaffold(body: Text('Pantalla de guias abierta')),
          },
          home: const Scaffold(appBar: _TestAppBar(), drawer: SideMenu()),
        ),
      ),
    );
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inventario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Firma Guias'));
    await tester.pumpAndSettle();
    expect(find.text('Pantalla de guias abierta'), findsOneWidget);
    expect(find.textContaining('Ruta no configurada'), findsNothing);
    final context = tester.element(find.text('Pantalla de guias abierta'));
    expect(
      AppRouter.getRoutes()[AppRouter.deliveryNotes]!(context),
      isA<DeliveryNotesScreen>(),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    auth.dispose();
    points.dispose();
  });
}

class _TestAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TestAppBar();
  @override
  Size get preferredSize => const Size.fromHeight(56);
  @override
  Widget build(BuildContext context) => AppBar(title: const Text('Inicio'));
}
