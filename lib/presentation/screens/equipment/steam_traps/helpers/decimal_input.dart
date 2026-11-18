import 'package:flutter/services.dart';

/// Decimal input shared by the UI and request validation (dot or comma).
class DecimalInput {
  static final _number = RegExp(r'^-?(?:[0-9]+(?:[.,][0-9]*)?|[.,][0-9]+)$');
  static final _editing = RegExp(r'^-?[0-9]*(?:[.,][0-9]*)?$');

  static double? parse(String text) {
    final value = text.trim();
    if (!_number.hasMatch(value)) return null;
    final number = double.tryParse(value.replaceAll(',', '.'));
    return number != null && number.isFinite ? number : null;
  }

  static final formatter = TextInputFormatter.withFunction((
    oldValue,
    newValue,
  ) {
    final text = newValue.text;
    // Allow intermediate edits such as '-' and ','; validation rejects them
    // until the user completes a number. Reject a whole invalid paste.
    if (!_editing.hasMatch(text)) return oldValue;
    if (RegExp(r'[0-9]').hasMatch(text) && parse(text) == null) return oldValue;
    return newValue;
  });
}
