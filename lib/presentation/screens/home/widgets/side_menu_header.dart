import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/presentation/providers/point_sales_provider.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/user_initials_avatar.dart';

class SideMenuHeader extends StatelessWidget {
  final String fullName;

  const SideMenuHeader({
       super.key,required this.fullName});

  @override
  Widget build(BuildContext context) {
    final pointSalesProvider = context.watch<PointSalesProvider>();
    final pvDescription = pointSalesProvider.isLoading
        ? 'Cargando punto de venta...'
        : pointSalesProvider.selectedPvDescription;
    final pvCode = pointSalesProvider.selectedPvCode;
    final canChangePointSale =
        pointSalesProvider.pointSales.length > 1 &&
        !pointSalesProvider.isLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 42, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.brand,
        border: Border(bottom: BorderSide(color: AppColors.card, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserInitialsAvatar(
            name: fullName,
            radius: 30,
            backgroundColor: AppColors.card,
            textColor: AppColors.brand,
          ),
          const SizedBox(height: 12),
          Text(
            fullName,
            style: const TextStyle(
              color: AppColors.onBrand,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 10),
          _PointSalesHeaderSelector(
            pvDescription : pvDescription,
            pvCode : pvCode,
            canChange : canChangePointSale,
            isLoading: pointSalesProvider.isLoading,
            onTap: canChangePointSale
                ? () => _showPointSaleSelector(context)
                : null,
          ),
        ],
      ),
    );
  }
  void _showPointSaleSelector(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(22),
      ),
    ),
    builder: (sheetContext) {
      return Consumer<PointSalesProvider>(
        builder: (context, pointSalesProvider, _) {
          final pointSales = pointSalesProvider.pointSales;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.muted.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Seleccionar punto de venta',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (pointSales.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No hay puntos de venta disponibles.',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: pointSales.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final pointSale = pointSales[index];
                          final isSelected =
                              pointSalesProvider.selectedPvId == pointSale.pvId;

                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: isSelected
                                  ? AppColors.brand
                                  : AppColors.muted,
                            ),
                            title: Text(
                              pointSale.pvDescription,
                              style: TextStyle(
                                color: AppColors.text,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Código: ${pointSale.pvCode}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () async {
                              await pointSalesProvider.changePointSale(pointSale);

                              if (!sheetContext.mounted) return;

                              Navigator.pop(sheetContext);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
}

class _PointSalesHeaderSelector extends StatelessWidget {
  final String pvDescription;
  final String pvCode;
  final bool canChange;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PointSalesHeaderSelector({
    required this.pvDescription,
    required this.pvCode,
    required this.canChange,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = pvCode.isEmpty ? 'Agencia actual '  : 'Código:$pvCode';

    return Material(
      color : Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                color: AppColors.onBrand,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pvDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.onBrand,
                      fontSize: 12,
                      fontWeight: FontWeight.w700
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.onBrand.withValues(alpha: 0.78),
                      fontSize: 11,
                      fontWeight: FontWeight.w400
                    ),
                  )
                ],
              ),
              ),
              if(isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onBrand,
                  ),
                )
              else if(canChange)
                 const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.onBrand,
                    size: 20,
                 ),
            ],
          ),
        ),
      ),
    );
  }
}
