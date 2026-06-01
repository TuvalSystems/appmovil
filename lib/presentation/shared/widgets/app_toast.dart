import 'package:flutter/material.dart';

enum AppToastType { success, error, warning, info }

class AppToast {
  static OverlayEntry? _currentToast;

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (message.trim().isEmpty) return;

    _currentToast?.remove();
    _currentToast = null;

    final overlay = Overlay.of(context);

    final entry = OverlayEntry(
      builder: (_) {
        return _ToastOverlay(
          message: message,
          type: type,
          duration: duration,
          onDismiss: () {
            _currentToast?.remove();
            _currentToast = null;
          },
        );
      },
    );
    _currentToast = entry;
    overlay.insert(entry);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: AppToastType.info);
  }

  static void auto(BuildContext context, String message) {
    final lowerMessage = message.toLowerCase();

    final isError =
        lowerMessage.contains('error') ||
        lowerMessage.contains('no se pudo') ||
        lowerMessage.contains('seleccione') ||
        lowerMessage.contains('válida') ||
        lowerMessage.contains('requiere revisión') ||
        lowerMessage.contains('exception');

    final isWarning =
        lowerMessage.contains('advertencia') ||
        lowerMessage.contains('validación') ||
        lowerMessage.contains('revise');

    if (isError) {
      error(context, message);
      return;
    }

    if (isWarning) {
      warning(context, message);
      return;
    }

    success(context, message);
  }
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final AppToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _ToastStyle get _style {
    switch (widget.type) {
      case AppToastType.success:
        return const _ToastStyle(
          backgroundColor: Color(0xff157347),
          borderColor: Color(0xff1fa463),
          icon: Icons.check_circle_outline,
        );

      case AppToastType.error:
        return const _ToastStyle(
          backgroundColor: Color(0xffb42318),
          borderColor: Color(0xffda2f22),
          icon: Icons.warning_amber_rounded,
        );

      case AppToastType.warning:
        return const _ToastStyle(
          backgroundColor: Color(0xffb7791f),
          borderColor: Color(0xffd69e2e),
          icon: Icons.info_outline,
        );

      case AppToastType.info:
        return const _ToastStyle(
          backgroundColor: Color(0xff2563eb),
          borderColor: Color(0xff3b82f6),
          icon: Icons.notifications_none,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: style.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: style.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(style.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async {
                        await _controller.reverse();

                        if (mounted) {
                          widget.onDismiss();
                        }
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastStyle {
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;

  const _ToastStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });
}
