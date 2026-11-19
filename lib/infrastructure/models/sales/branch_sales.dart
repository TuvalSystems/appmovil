enum SalesPeriod {
  today('Hoy', 'subTotalDiaHoy', 'extCostDiaHoy'),
  yesterday('Ayer', 'subTotalAyer', 'extCostAyer'),
  selected('Período consultado', 'subTotalMes', 'extCostMes'),
  previousMonth('Mes anterior', 'subtotalMesAnterior', 'extCostMesAnterior'),
  twoMonthsAgo('Hace dos meses', 'subtotalMesAnterior2', 'extCostMesAnterior2'),
  currentYear('Año actual', 'subtotalAnioActual', 'extCostAnioActual'),
  previousYear(
    'Año anterior al corte',
    'subtotalAnioAtras',
    'extCostAnioAtras',
  );

  const SalesPeriod(this.label, this.salesKey, this.costKey);
  final String label, salesKey, costKey;
}

typedef SalesAmounts = ({num? sales, num? cost});

class BranchSales {
  const BranchSales(this.name, this.periods);

  final String? name;
  final Map<SalesPeriod, SalesAmounts> periods;

  factory BranchSales.fromJson(Map<String, dynamic> json) {
    num? amount(String key) {
      final value = json[key];
      if (value == null && json.containsKey(key)) return null;
      if (value is num && value.isFinite) return value;
      throw FormatException('Importe inválido: $key');
    }

    final name = json['txNom'];
    if (!json.containsKey('txNom') || (name != null && name is! String)) {
      throw const FormatException('Sucursal inválida');
    }
    return BranchSales(
      (name as String?)?.trim(),
      Map.unmodifiable({
        for (final period in SalesPeriod.values)
          period: (
            sales: amount(period.salesKey),
            cost: amount(period.costKey),
          ),
      }),
    );
  }

  static SalesAmounts total(List<BranchSales> branches, SalesPeriod period) {
    num? sales;
    num? cost;
    for (final branch in branches) {
      final amounts = branch.periods[period]!;
      if (amounts.sales case final value?) sales = (sales ?? 0) + value;
      if (amounts.cost case final value?) cost = (cost ?? 0) + value;
    }
    return (sales: sales, cost: cost);
  }
}
