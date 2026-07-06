import 'package:flutter/material.dart';

enum ButtonInteractionState {
  normal,
  pressed,
  disabled,
  loading,
  success,
  error,
}

class SleekButtonInteraction extends StatefulWidget {
  final Widget child;
  final ButtonInteractionState state;
  final VoidCallback? onPressed;
  final double scaleFactor;
  final Duration duration;

  const SleekButtonInteraction({
    super.key,
    required this.child,
    this.state = ButtonInteractionState.normal,
    this.onPressed,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<SleekButtonInteraction> createState() => _SleekButtonInteractionState();
}

class _SleekButtonInteractionState extends State<SleekButtonInteraction>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.state == ButtonInteractionState.disabled ||
        widget.state == ButtonInteractionState.loading) {
      return;
    }
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.state == ButtonInteractionState.disabled ||
        widget.state == ButtonInteractionState.loading) {
      return;
    }
    _scaleController.reverse();
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.state == ButtonInteractionState.disabled;
    final bool isLoading = widget.state == ButtonInteractionState.loading;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor:
          isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isDisabled ? 0.6 : 1.0,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                boxShadow: [
                  BoxShadow(
                    color: _getGlowColor()
                        .withValues(alpha: _isHovered ? 0.35 : 0.2),
                    blurRadius: _isHovered ? 12 : 8,
                    spreadRadius: _isHovered ? 2 : 0.5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  widget.child,

                  // Loading Indicator Overlay
                  if (isLoading)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(34),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getGlowColor() {
    switch (widget.state) {
      case ButtonInteractionState.success:
        return const Color(0xFF00C853);
      case ButtonInteractionState.error:
        return const Color(0xFFFF1744);
      case ButtonInteractionState.disabled:
        return Colors.transparent;
      case ButtonInteractionState.normal:
      default:
        return const Color(0xFFFFD700);
    }
  }
}
