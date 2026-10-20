import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/presentation/providers/point_sales_provider.dart';
import 'package:tuvalapp/presentation/screens/home/widgets/user_initials_avatar.dart';

class SideMenuHeader extends StatelessWidget {
  final String fullName;

  const SideMenuHeader({super.key, required this.fullName});

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
      padding: EdgeInsets.fromLTRB(16, 42, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.brand,
        border: Border(
          bottom: BorderSide(color: context.appColors.card, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserInitialsAvatar(
            name: fullName,
            radius: 30,
            backgroundColor: context.appColors.card,
            textColor: AppColors.brand,
          ),
          SizedBox(height: 12),
          Text(
            fullName,
            style: TextStyle(
              color: AppColors.onBrand,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          SizedBox(height: 10),
          _PointSalesHeaderSelector(
            pvDescription: pvDescription,
            pvCode: pvCode,
            canChange: canChangePointSale,
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
      backgroundColor: context.appColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Consumer<PointSalesProvider>(
          builder: (context, pointSalesProvider, _) {
            final pointSales = pointSalesProvider.pointSales;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 42,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: context.appColors.muted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Seleccionar punto de venta',
                        style: TextStyle(
                          color: context.appColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    if (pointSales.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No hay puntos de venta disponibles.',
                          style: TextStyle(
                            color: context.appColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: pointSales.length,
                          separatorBuilder: (_, __) => Divider(height: 1),
                          itemBuilder: (context, index) {
                            final pointSale = pointSales[index];
                            final isSelected =
                                pointSalesProvider.selectedPvId ==
                                pointSale.pvId;

                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? AppColors.brand
                                    : context.appColors.muted,
                              ),
                              title: Text(
                                pointSale.pvDescription,
                                style: TextStyle(
                                  color: context.appColors.text,
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                'Código: ${pointSale.pvCode}',
                                style: TextStyle(
                                  color: context.appColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                              onTap: () async {
                                await pointSalesProvider.changePointSale(
                                  pointSale,
                                );

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
    final subtitle = pvCode.isEmpty ? 'Agencia actual ' : 'Código:$pvCode';

    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Icon(
                Icons.storefront_outlined,
                color: AppColors.onBrand,
                size: 18,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pvDescription,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.onBrand,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.onBrand.withValues(alpha: 0.78),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.onBrand,
                  ),
                )
              else if (canChange)
                Icon(
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
