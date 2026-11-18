import 'package:flutter/material.dart';
import 'package:tuvalapp/presentation/screens/equipment/steam_traps/helpers/decimal_input.dart';
import 'package:tuvalapp/config/theme/app_theme.dart';

class SteamTrapInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final TextInputType keyboardType;

  const SteamTrapInput({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
      signed: true,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final bool isTextField = keyboardType == TextInputType.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        SizedBox(height: 8),
        SizedBox(
          height: 46,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: isTextField ? null : [DecimalInput.formatter],
            textInputAction: TextInputAction.done,
            onChanged: (_) => onChanged(),
            onSubmitted: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            onTapOutside: (_) {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            decoration: InputDecoration(
              hintText: isTextField ? 'Escriba aquí' : '0.00',
              filled: true,
              fillColor: context.appColors.card,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: context.appColors.border,
                  width: 0.7,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: context.appColors.border,
                  width: 0.7,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.brand, width: 1.2),
              ),
            ),
          ),
        ),
      ],
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
