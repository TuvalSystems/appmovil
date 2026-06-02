import 'dart:async';

import 'package:flutter/material.dart';

enum AppToastType { success, error, warning, info }

enum AppToastPosition { top, bottom }

class AppToast {
  static OverlayEntry? _currentToast;

  static void show(
    BuildContext context, {
    required String message,
    AppToastType type = AppToastType.info,
    Duration duration = const Duration(seconds: 3),
    AppToastPosition position = AppToastPosition.bottom,
  }) {
    final cleanMessage = message.trim();

    if (cleanMessage.isEmpty) return;

    _currentToast?.remove();
    _currentToast = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);

    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (_) {
        return _ToastOverlay(
          message: cleanMessage,
          type: type,
          duration: duration,
          position: position,
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

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: AppToastType.success,
      duration: duration,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: AppToastType.error,
      duration: duration,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      type: AppToastType.warning,
      duration: duration,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      type: AppToastType.info,
      duration: duration,
    );
  }

  static void auto(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final lowerMessage = message.toLowerCase();

    final isError =
        lowerMessage.contains('error') ||
        lowerMessage.contains('no se pudo') ||
        lowerMessage.contains('seleccione') ||
        lowerMessage.contains('válida') ||
        lowerMessage.contains('valida') ||
        lowerMessage.contains('requiere revisión') ||
        lowerMessage.contains('exception') ||
        lowerMessage.contains('falló') ||
        lowerMessage.contains('fallo');

    final isWarning =
        lowerMessage.contains('advertencia') ||
        lowerMessage.contains('validación') ||
        lowerMessage.contains('validacion') ||
        lowerMessage.contains('revise') ||
        lowerMessage.contains('revisar');

    if (isError) {
      error(context, message, duration: duration);
      return;
    }

    if (isWarning) {
      warning(context, message, duration: duration);
      return;
    }

    success(context, message, duration: duration);
  }
}

class _ToastOverlay extends StatefulWidget {
  final String message;
  final AppToastType type;
  final Duration duration;
  final AppToastPosition position;
  final VoidCallback onDismiss;

  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.position,
    required this.onDismiss,
  });

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    final isTop = widget.position == AppToastPosition.top;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 180),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, isTop ? -0.18 : 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();

    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_isDismissing || !mounted) return;

    _isDismissing = true;
    _dismissTimer?.cancel();

    await _controller.reverse();

    if (mounted) {
      widget.onDismiss();
    }
  }

  _ToastStyle get _style {
    switch (widget.type) {
      case AppToastType.success:
        return const _ToastStyle(
          title: 'Éxito',
          accentColor: Color(0xff22c55e),
          iconBackgroundColor: Color(0xffdcfce7),
          iconColor: Color(0xff15803d),
          icon: Icons.check_rounded,
        );

      case AppToastType.error:
        return const _ToastStyle(
          title: 'Error',
          accentColor: Color(0xffef4444),
          iconBackgroundColor: Color(0xffffe4e6),
          iconColor: Color(0xffbe123c),
          icon: Icons.close_rounded,
        );

      case AppToastType.warning:
        return const _ToastStyle(
          title: 'Advertencia',
          accentColor: Color(0xfff59e0b),
          iconBackgroundColor: Color(0xfffff7ed),
          iconColor: Color(0xffb45309),
          icon: Icons.priority_high_rounded,
        );

      case AppToastType.info:
        return const _ToastStyle(
          title: 'Información',
          accentColor: Color(0xff3b82f6),
          iconBackgroundColor: Color(0xffdbeafe),
          iconColor: Color(0xff1d4ed8),
          icon: Icons.notifications_none_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final mediaQuery = MediaQuery.of(context);
    final isTop = widget.position == AppToastPosition.top;

    final double bottomOffset = 18 + mediaQuery.viewInsets.bottom;
    const double topOffset = 18;

    return Positioned(
      left: 16,
      right: 16,
      top: isTop ? topOffset : null,
      bottom: isTop ? null : bottomOffset,
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 0),
        child: Align(
          alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xff111827),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Container(
                              width: 5,
                              color: style.accentColor,
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  13,
                                  10,
                                  13,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: style.iconBackgroundColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        style.icon,
                                        color: style.iconColor,
                                        size: 21,
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            style.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w800,
                                              height: 1.15,
                                            ),
                                          ),

                                          const SizedBox(height: 3),

                                          Text(
                                            widget.message,
                                            style: TextStyle(
                                              color:
                                                  Colors.white.withValues(alpha: 0.86),
                                              fontSize: 12.8,
                                              fontWeight: FontWeight.w500,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 6),

                                    InkWell(
                                      onTap: _dismiss,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: Colors.white.withValues(alpha: 0.72),
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
  final String title;
  final Color accentColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final IconData icon;

  const _ToastStyle({
    required this.title,
    required this.accentColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.icon,
  });
}