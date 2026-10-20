import 'package:tuvalapp/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SteamTrapDropdown extends StatelessWidget {
  final String? label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const SteamTrapDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = items.contains(value)
        ? value
        : items.isNotEmpty
        ? items.first
        : null;

    final dropdown = Container(
      height: 46,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appColors.border, width: 0.7),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: safeValue,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.appColors.text,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: context.appColors.text),
              ),
            );
          }).toList(),
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ),
    );

    if (label == null || label!.isEmpty) {
      return dropdown;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_Label(label!), SizedBox(height: 8), dropdown],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: context.appColors.muted,
      ),
    );
  }
}
