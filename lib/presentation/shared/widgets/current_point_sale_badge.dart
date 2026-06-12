import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:tuvalapp/presentation/providers/point_sales_provider.dart';

class CurrentPointSaleBadge extends StatelessWidget {
  const CurrentPointSaleBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final pointSalesProvider = context.watch<PointSalesProvider>();

    final isLoading = pointSalesProvider.isLoading;
    final pvDescription = pointSalesProvider.selectedPvDescription;
    final pvCode = pointSalesProvider.selectedPvCode;

    final text = isLoading
        ? 'Cargando agencia...'
        : pvCode.isEmpty
        ? pvDescription
        : '$pvDescription · $pvCode';

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 036,
      ),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.storefront_outlined,
              color: AppColors.onBrand,
              size: 14,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.onBrand,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
