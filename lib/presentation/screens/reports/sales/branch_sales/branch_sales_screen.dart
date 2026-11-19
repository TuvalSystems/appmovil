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
            BranchSalesTable(rows: state.rows),
            const SizedBox(height: 8),
            const Text(
              '— indica un dato no disponible. Los totales se calculan '
              'sobre sucursales con datos informados para cada período. '
              'Si falta un importe de un par informado, no se muestra el margen.',
            ),
          ],
        ],
      ),
    );
  }
}

class BranchSalesTable extends StatefulWidget {
  const BranchSalesTable({super.key, required this.rows});

  final List<BranchSales> rows;

  @override
  State<BranchSalesTable> createState() => _BranchSalesTableState();
}

enum _BranchSalesMetric {
  sales('Ventas'),
  cost('Costo'),
  margin('GM (%)');

  const _BranchSalesMetric(this.label);
  final String label;
}

class _BranchSalesTableState extends State<BranchSalesTable> {
  _BranchSalesMetric _metric = _BranchSalesMetric.sales;

  static const _labels = [
    'Hoy',
    'Ayer',
    'Período',
    'Mes anterior',
    'Hace 2 meses',
    'YTD',
    'PYTD',
  ];
  static const _rowHeight = 40.0;
  static const _branchWidth = 128.0;
  static const _periodWidth = 112.0;

  static String _money(num? amount) =>
      amount == null ? '—' : '\$${amount.toStringAsFixed(2)}';

  static String _margin(SalesAmounts amounts) {
    final margin = BranchSales.grossMargin(amounts);
    return margin == null ? '—' : '${(margin * 100).toStringAsFixed(1)}%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final firstHeader = colors.surfaceContainerHighest;
    final monthHeader = Color.alphaBlend(
      colors.primary.withValues(alpha: 0.19),
      colors.surface,
    );
    final yearHeader = Color.alphaBlend(
      colors.tertiary.withValues(alpha: 0.19),
      colors.surface,
    );
    final textStyle = theme.textTheme.labelMedium?.copyWith(
      color: colors.onSurface,
    );
    final totals = [
      for (final period in SalesPeriod.values)
        BranchSales.total(widget.rows, period),
    ];

    Color band(int i) => i < 2
        ? firstHeader
        : i < 5
        ? monthHeader
        : yearHeader;

    Widget cell(
      String label,
      double width, {
      bool right = false,
      bool emphasis = false,
      Color? background,
    }) {
      return Container(
        width: width,
        height: _rowHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: background ?? colors.surface,
          border: Border(
            right: BorderSide(color: colors.outlineVariant),
            bottom: BorderSide(color: colors.outlineVariant),
          ),
        ),
        alignment: right ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: right ? TextAlign.right : TextAlign.left,
          style: emphasis
              ? textStyle?.copyWith(fontWeight: FontWeight.bold)
              : textStyle,
        ),
      );
    }

    Widget numericRow(
      List<String> cells, {
      bool emphasis = false,
      bool right = true,
    }) {
      return Row(
        children: [
          for (var i = 0; i < cells.length; i++)
            cell(
              cells[i],
              _periodWidth,
              right: right,
              emphasis: emphasis,
              background: emphasis ? band(i) : null,
            ),
        ],
      );
    }

    String formatBranch(SalesAmounts? amounts) {
      if (amounts == null) return '—';
      return switch (_metric) {
        _BranchSalesMetric.sales => _money(amounts.sales),
        _BranchSalesMetric.cost => _money(amounts.cost),
        _BranchSalesMetric.margin => _margin(amounts),
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('Ver por sucursal:'),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButton<_BranchSalesMetric>(
                isExpanded: true,
                value: _metric,
                items: [
                  for (final metric in _BranchSalesMetric.values)
                    DropdownMenuItem(value: metric, child: Text(metric.label)),
                ],
                onChanged: (metric) {
                  if (metric != null) setState(() => _metric = metric);
                },
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                cell(
                  'Sucursal',
                  _branchWidth,
                  emphasis: true,
                  background: firstHeader,
                ),
                for (final branch in widget.rows)
                  cell(
                    (branch.name?.isNotEmpty ?? false)
                        ? branch.name!
                        : 'Sucursal sin nombre',
                    _branchWidth,
                  ),
                for (final label in ['TOTAL', 'Costo', 'GM (%)'])
                  cell(
                    label,
                    _branchWidth,
                    emphasis: true,
                    background: firstHeader,
                  ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                key: const ValueKey('branch-sales-periods'),
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    numericRow(_labels, emphasis: true, right: false),
                    for (final branch in widget.rows)
                      numericRow([
                        for (final period in SalesPeriod.values)
                          formatBranch(branch.periods[period]),
                      ]),
                    numericRow([
                      for (final value in totals) _money(value.sales),
                    ], emphasis: true),
                    numericRow([
                      for (final value in totals) _money(value.cost),
                    ], emphasis: true),
                    numericRow([
                      for (final value in totals) _margin(value),
                    ], emphasis: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
