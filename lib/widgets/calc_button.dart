import 'package:flutter/material.dart';
import '../services/haptic_settings.dart';
import '../theme/app_theme.dart';

/// Premium calculator button with glassmorphism, press-scale animation,
/// shimmer highlight, and haptic feedback.
class CalcButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final CalcButtonType type;
  final int flex;
  final IconData? icon;

  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.type = CalcButtonType.number,
    this.flex = 1,
    this.icon,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _controller.forward();
    HapticSettings.light(context);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final content = Semantics(
      button: true,
      label: _semanticLabel,
      child: GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(4),
          decoration: _buildDecoration(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shimmer highlight when pressed
              if (_isPressed)
                Positioned(
                  top: -20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // Content
              Center(
                child: widget.icon != null
                    ? Icon(widget.icon, color: _iconColor, size: 22)
                    : Text(widget.label, style: _textStyle),
              ),
            ],
          ),
        ),
        ),
      ),
    );

    if (widget.flex <= 0) return content;
    return Expanded(flex: widget.flex, child: content);
  }

  String get _semanticLabel {
    final label = widget.label;
    switch (widget.type) {
      case CalcButtonType.operator:
        const names = {'+': 'plus', '−': 'minus', '×': 'multiply', '÷': 'divide'};
        return names[label] ?? 'Operator $label';
      case CalcButtonType.function:
        return 'Function $label';
      case CalcButtonType.equals:
        return 'Equals';
      case CalcButtonType.delete:
        return label == 'C' ? 'Clear' : 'Backspace';
      case CalcButtonType.number:
        return label;
    }
  }

  BoxDecoration _buildDecoration() {
    switch (widget.type) {
      case CalcButtonType.equals:
        return BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.accentStart.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: AppTheme.accentEnd.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: -2,
                    offset: const Offset(0, 10),
                  ),
                ],
        );
      case CalcButtonType.operator:
        return BoxDecoration(
          color: _isPressed
              ? AppTheme.operatorColor.withValues(alpha: 0.12)
              : AppTheme.bgElevated.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.operatorColor.withValues(
              alpha: _isPressed ? 0.4 : 0.2,
            ),
            width: 1.5,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.operatorColor.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        );
      case CalcButtonType.function:
        return BoxDecoration(
          color: _isPressed
              ? AppTheme.functionColor.withValues(alpha: 0.1)
              : AppTheme.surface.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.functionColor.withValues(
              alpha: _isPressed ? 0.3 : 0.12,
            ),
            width: 1,
          ),
        );
      case CalcButtonType.delete:
        return BoxDecoration(
          color: _isPressed
              ? AppTheme.deleteColor.withValues(alpha: 0.12)
              : AppTheme.surface.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: AppTheme.deleteColor.withValues(
              alpha: _isPressed ? 0.4 : 0.15,
            ),
            width: 1,
          ),
        );
      case CalcButtonType.number:
        return BoxDecoration(
          color: _isPressed
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          border: Border.all(
            color: Colors.white.withValues(alpha: _isPressed ? 0.1 : 0.05),
            width: 1,
          ),
        );
    }
  }

  TextStyle get _textStyle {
    switch (widget.type) {
      case CalcButtonType.operator:
        return AppTheme.operatorText;
      case CalcButtonType.function:
        return AppTheme.functionText;
      case CalcButtonType.delete:
        return AppTheme.buttonTextSmall.copyWith(color: AppTheme.deleteColor);
      case CalcButtonType.equals:
        return AppTheme.buttonText.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 30,
        );
      case CalcButtonType.number:
        return AppTheme.buttonText;
    }
  }

  Color get _iconColor {
    switch (widget.type) {
      case CalcButtonType.operator:
        return AppTheme.operatorColor;
      case CalcButtonType.function:
        return AppTheme.functionColor;
      case CalcButtonType.delete:
        return AppTheme.deleteColor;
      case CalcButtonType.equals:
        return Colors.white;
      case CalcButtonType.number:
        return AppTheme.textPrimary;
    }
  }
}

enum CalcButtonType { number, operator, function, equals, delete }
