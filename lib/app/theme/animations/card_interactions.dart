import 'package:flutter/material.dart';

class SleekCardInteraction extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double liftOffset;
  final Duration duration;

  const SleekCardInteraction({
    super.key,
    required this.child,
    this.onTap,
    this.liftOffset = -3.0,
    this.duration = const Duration(milliseconds: 180),
  });

  @override
  State<SleekCardInteraction> createState() => _SleekCardInteractionState();
}

class _SleekCardInteractionState extends State<SleekCardInteraction> {
  bool _isPressed = false;
  bool _isHovered = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    if (!_isPressed) return;
    setState(() => _isPressed = false);
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _isPressed || _isHovered;
    final double currentLift = active ? widget.liftOffset : 0.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0.0, currentLift, 0.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A1B9A)
                    .withValues(alpha: active ? 0.25 : 0.1),
                blurRadius: active ? 16 : 8,
                spreadRadius: active ? 2 : 0.5,
                offset: Offset(0, active ? 6 : 3),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
