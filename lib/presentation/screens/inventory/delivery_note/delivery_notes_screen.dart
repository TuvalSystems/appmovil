import 'package:tuvalapp/infrastructure/datasources/customers_datasource.dart';
import 'package:tuvalapp/presentation/screens/inventory/delivery_note/delivery_note_files_screen.dart';
import 'package:flutter/material.dart';
import 'package:tuvalapp/infrastructure/datasources/delivery_notes_datasource.dart';
import 'delivery_note_qr_screen.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/presentation/shared/widgets/customer_search_card.dart';
import 'package:tuvalapp/presentation/providers/point_sales_provider.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/side_menu.dart';
import 'package:tuvalapp/presentation/screens/inventory/delivery_note/providers/delivery_notes_provider.dart';
import 'package:tuvalapp/presentation/shared/widgets/tuval_app_bar.dart';

class DeliveryNotesScreen extends StatelessWidget {
  const DeliveryNotesScreen({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (context) => DeliveryNotesProvider(
      datasource: context.read<DeliveryNotesDatasource>(),
      customersDatasource: context.read<CustomersDatasource>(),
    ),
    child: const _DeliveryNotesView(),
  );
}

class _DeliveryNotesView extends StatefulWidget {
  const _DeliveryNotesView();
  @override
  State<_DeliveryNotesView> createState() => _DeliveryNotesViewState();
}

class _DeliveryNotesViewState extends State<_DeliveryNotesView> {
  final _scroll = ScrollController();
  bool _resolvingQr = false;
  PointSalesProvider? _points;
  DeliveryNotesProvider? _notes;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 250) {
        final provider = context.read<DeliveryNotesProvider>();
        if (provider.error == null) provider.loadMore();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final points = context.read<PointSalesProvider>();
    await points.loadPointSales();
    if (!mounted) return;
    _points?.removeListener(_syncPointSale);
    _points = points;
    _notes = context.read<DeliveryNotesProvider>();
    points.addListener(_syncPointSale);
    await _notes!.initialize(points.selectedPvId);
    if (mounted) _syncPointSale();
  }

  void _syncPointSale() {
    final notes = _notes;
    if (!mounted || notes == null || notes.initializing) return;
    final activeId = _points?.selectedPvId;
    if (notes.pointSaleId != activeId) notes.changePointSale(activeId);
  }

  Future<void> _scanQr() async {
    if (_resolvingQr) return;
    setState(() => _resolvingQr = true);
    try {
      final value = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const DeliveryNoteQrScreen()),
      );
      if (!mounted || value == null) return;
      final datasource = context.read<DeliveryNotesProvider>().datasource;
      final guide = await datasource.resolveQr(value);
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => DeliveryNoteFilesScreen(
            guide: guide,
            datasource: datasource,
            openSignature: true,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _resolvingQr = false);
    }
  }

  @override
  void dispose() {
    _points?.removeListener(_syncPointSale);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DeliveryNotesProvider>();
    return Scaffold(
      drawer: const SideMenu(),
      appBar: const TuvalAppBar(
        title: 'Guías de remisión',
        showPointSale: true,
      ),
      body: RefreshIndicator(
        onRefresh: state.ready ? state.refresh : _initialize,
        child: ListView.builder(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          itemCount: state.items.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) return _filters(state);
            if (index == state.items.length + 1) return _footer(state);
            final guide = state.items[index - 1];
            return Card(
              key: ValueKey('${guide.type}-${guide.id}'),
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                trailing: const Icon(Icons.draw_outlined),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DeliveryNoteFilesScreen(
                      guide: guide,
                      datasource: state.datasource,
                    ),
                  ),
                ),
                title: Text(
                  guide.number,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${_typeLabel(state, guide.type)} · Fecha de salida: ${guide.departureDateLabel}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _typeLabel(DeliveryNotesProvider state, String type) =>
      state.types.where((option) => option.id == type).firstOrNull?.label ??
      type;

  Widget _filters(DeliveryNotesProvider state) {
    final points = context.watch<PointSalesProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Consultar guías',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 6),
        Text(
          state.isDispatch
              ? 'Despachos enviados desde el punto de venta seleccionado.'
              : 'Guías recibidas en el punto de venta activo. Puede filtrar por la bodega de origen.',
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _resolvingQr ? null : _scanQr,
          icon: const Icon(Icons.qr_code_scanner),
          label: Text(_resolvingQr ? 'Validando guía...' : 'Leer QR'),
        ),
        const SizedBox(height: 12),
        if (state.initializing || points.isLoading)
          const LinearProgressIndicator(),
        if (state.catalogError != null || points.errorMessage != null)
          _message(state.catalogError ?? points.errorMessage!, _initialize),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey('type-${state.type}'),
          initialValue: state.type,
          decoration: const InputDecoration(
            labelText: 'Tipo de guía',
            border: OutlineInputBorder(),
          ),
          items: state.types
              .map(
                (type) =>
                    DropdownMenuItem(value: type.id, child: Text(type.label)),
              )
              .toList(),
          onChanged: state.initializing
              ? null
              : (value) {
                  if (value != null) state.changeType(value);
                },
        ),
        const SizedBox(height: 14),
        if (!state.isDispatch)
          DropdownButtonFormField<int>(
            key: ValueKey('origin-warehouse-${state.originWarehouseId}'),
            initialValue: state.originWarehouseId ?? 0,
            decoration: const InputDecoration(
              labelText: 'Bodega de origen',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(
                value: 0,
                child: Text('Todas las bodegas'),
              ),
              ...state.warehouses.map(
                (warehouse) => DropdownMenuItem(
                  value: int.parse(warehouse.id),
                  child: Text(warehouse.label),
                ),
              ),
            ],
            onChanged: state.initializing
                ? null
                : (value) =>
                      state.changeOriginWarehouse(value == 0 ? null : value),
          ),
        if (state.isDispatch)
          CustomerSearchCard(
            controller: state.customerSearch,
            description:
                'Busque y seleccione un cliente para filtrar los despachos. Deje el campo vacío para ver todos.',
          ),
        const SizedBox(height: 20),
        if (!state.loading)
          Text(
            '${state.total} guías',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _footer(DeliveryNotesProvider state) {
    if (state.loading || state.loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.error != null) {
      return _message(
        state.error!,
        state.items.isEmpty ? state.refresh : state.loadMore,
      );
    }
    if (state.catalogError != null || state.initializing) {
      return const SizedBox.shrink();
    }
    if (state.pointSaleId == null) {
      return const Text(
        'No hay un punto de venta activo. Selecciónelo desde el menú de la app.',
      );
    }
    if (state.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'No se encontraron guías con estos filtros.',
          textAlign: TextAlign.center,
        ),
      );
    }
    if (state.hasMore) {
      return OutlinedButton(
        onPressed: state.loadMore,
        child: const Text('Cargar más'),
      );
    }
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text('Has visto todas las guías.', textAlign: TextAlign.center),
    );
  }

  Widget _message(String message, Future<void> Function() retry) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Column(
      children: [
        Text(message, textAlign: TextAlign.center),
        TextButton(onPressed: retry, child: const Text('Reintentar')),
      ],
    ),
  );
}
