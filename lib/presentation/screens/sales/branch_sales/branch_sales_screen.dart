import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/infrastructure/datasources/branch_sales_datasource.dart';
import 'package:tuvalapp/infrastructure/models/menu/app_menu_model.dart';
import 'package:tuvalapp/infrastructure/models/sales/branch_sales.dart';
import 'package:tuvalapp/presentation/providers/auth_provider.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/side_menu.dart';
import 'package:tuvalapp/presentation/shared/helpers/mobile_menu_mapper.dart';
import 'package:tuvalapp/presentation/shared/widgets/tuval_app_bar.dart';

import 'providers/branch_sales_provider.dart';

class BranchSalesScreen extends StatelessWidget {
  const BranchSalesScreen({super.key});

  static const title = 'Listado de ventas por sucursal';

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    bool hasRoute(AppMenuItem item) =>
        item.route == MobileMenuMapper.branchSalesMenuRoute ||
        item.children.any(hasRoute);

    if (auth.authStatus != AuthStatus.authenticated ||
        auth.user?.appAccess != true ||
        auth.user?.status != true ||
        !MobileMenuMapper.isBranchSalesAdministrator(
          auth.user?.appProfileName,
        ) ||
        !(auth.appMenu?.items.any(hasRoute) ?? false)) {
      return const Scaffold(
        appBar: TuvalAppBar(title: title, showPointSale: false),
        body: Center(
          child: Text('No tiene permiso para consultar este listado.'),
        ),
      );
    }
    return ChangeNotifierProvider(
      create: (context) =>
          BranchSalesProvider(context.read<BranchSalesDatasource>()),
      child: const _BranchSalesView(),
    );
  }
}

class _BranchSalesView extends StatefulWidget {
  const _BranchSalesView();

  @override
  State<_BranchSalesView> createState() => _BranchSalesViewState();
}

class _BranchSalesViewState extends State<_BranchSalesView> {
  late DateTimeRange _range;

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _range = DateTimeRange(
      start: DateTime(today.year, today.month),
      end: today,
    );
  }

  Future<void> _selectRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(9999, 12, 31),
      initialDateRange: _range,
    );
    if (!mounted || range == null) return;
    setState(() => _range = range);
    context.read<BranchSalesProvider>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BranchSalesProvider>();
    final localizations = MaterialLocalizations.of(context);
    final from = localizations.formatCompactDate(_range.start);
    final to = localizations.formatCompactDate(_range.end);

    return Scaffold(
      drawer: const SideMenu(),
      appBar: const TuvalAppBar(
        title: BranchSalesScreen.title,
        showPointSale: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          OutlinedButton.icon(
            onPressed: state.isLoading ? null : _selectRange,
            icon: const Icon(Icons.date_range_outlined),
            label: Text('$from – $to'),
          ),
          const Text(
            'El rango solo afecta al período consultado. '
            'Los demás comparativos se calculan con la fecha del servidor.',
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: state.isLoading
                ? null
                : () => state.load(_range.start, _range.end),
            child: Text(state.error == null ? 'Consultar' : 'Reintentar'),
          ),
          const SizedBox(height: 12),
          if (state.isLoading)
            const LinearProgressIndicator()
          else if (state.error case final error?)
            Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          else if (state.hasSearched && state.rows.isEmpty)
            const Text('No se encontraron sucursales para la consulta.')
          else if (state.rows.isNotEmpty) ...[
            _BranchCard(
              name: 'Totales del listado',
              periods: {
                for (final period in SalesPeriod.values)
                  period: BranchSales.total(state.rows, period),
              },
              summary: true,
            ),
            for (final row in state.rows)
              _BranchCard(
                name: (row.name?.isNotEmpty ?? false)
                    ? row.name!
                    : 'Sucursal sin nombre',
                periods: row.periods,
              ),
          ],
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.name,
    required this.periods,
    this.summary = false,
  });

  final String name;
  final Map<SalesPeriod, SalesAmounts> periods;
  final bool summary;

  static String _money(num? amount) =>
      amount == null ? '—' : '\$${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text(name),
        subtitle: Text(
          'Ventas del período: ${_money(periods[SalesPeriod.selected]!.sales)}',
        ),
        initiallyExpanded: summary,
        children: [
          if (summary)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Totales de importes disponibles en esta consulta.'),
            ),
          for (final period in SalesPeriod.values)
            ListTile(
              title: Text(period.label),
              subtitle: Text(
                'Ventas: ${_money(periods[period]!.sales)} · '
                'Costo: ${_money(periods[period]!.cost)}',
              ),
            ),
        ],
      ),
    );
  }
}
