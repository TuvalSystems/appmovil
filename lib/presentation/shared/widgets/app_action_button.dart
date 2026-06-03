import 'package:flutter/material.dart';

enum AppActionButtonType { primary, secondary, outline, danger }

class AppActionButton extends StatelessWidget {
  const AppActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.loadingLabel,
    this.isDisabled = false,
    this.fullWidth = true,
    this.variant = AppActionButtonType.primary,
  });

  final String label;
  final String? loadingLabel;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;
  final AppActionButtonType variant;

  bool get _isButtonDisabled {
    return isDisabled || onPressed == null;
  }

  @override
  Widget build(BuildContext context) {
    final button = AbsorbPointer(
      absorbing: isLoading,
      child: _buildButton(context),
    );

    if (!fullWidth) {
      return SizedBox(
        height: 44,
        child: button,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 44,
      child: button,
    );
  }

  Widget _buildButton(BuildContext context) {
    switch (variant) {
      case AppActionButtonType.primary:
        return ElevatedButton(
          onPressed: _isButtonDisabled ? null : onPressed,
          style: _buttonStyle(context),
          child: _buildContent(),
        );

      case AppActionButtonType.secondary:
        return FilledButton.tonal(
          onPressed: _isButtonDisabled ? null : onPressed,
          style: _buttonStyle(context),
          child: _buildContent(),
        );

      case AppActionButtonType.outline:
        return OutlinedButton(
          onPressed: _isButtonDisabled ? null : onPressed,
          style: _buttonStyle(context),
          child: _buildContent(),
        );

      case AppActionButtonType.danger:
        return ElevatedButton(
          onPressed: _isButtonDisabled ? null : onPressed,
          style: _dangerButtonStyle(context),
          child: _buildContent(),
        );
    }
  }

  Widget _buildContent() {
    final text = isLoading ? loadingLabel ?? label : label;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 16),

        if (isLoading || icon != null) const SizedBox(width: 8),

        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  ButtonStyle _dangerButtonStyle(BuildContext context) {
    return _buttonStyle(context).copyWith(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) {
          return Theme.of(context).disabledColor;
        }

        return Theme.of(context).colorScheme.error;
      }),
      foregroundColor: WidgetStateProperty.all(
        Theme.of(context).colorScheme.onError,
      ),
    );
  }
}