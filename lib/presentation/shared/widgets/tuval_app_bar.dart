import 'package:flutter/material.dart';
import 'package:tuvalapp/presentation/shared/widgets/current_point_sale_badge.dart';

class TuvalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showPointSale;
  final List<Widget>? actions;

  const TuvalAppBar({
    super.key,
    this.title = 'Tuval',
    this.showPointSale = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final appBarActions = <Widget>[
      if (showPointSale) const Center(child: CurrentPointSaleBadge()),
      ...?actions,
    ];

    return AppBar(
      toolbarHeight: 60,
      title: Text(title),
      actions: appBarActions.isEmpty ? null : appBarActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
