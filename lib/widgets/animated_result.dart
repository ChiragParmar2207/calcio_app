import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Odometer-style animated digit roller.
/// Each character in the result string gets its own vertical scroll animation.
/// Numbers roll smoothly, operators/symbols snap in with a fade.
class AnimatedResultDisplay extends StatelessWidget {
  final String value;
  final double fontSize;
  final bool useGradient;
  final bool isError;

  const AnimatedResultDisplay({
    super.key,
    required this.value,
    this.fontSize = 56,
    this.useGradient = true,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.isEmpty ? '0' : value;
    // Compute adaptive font size
    final adaptiveSize = _computeFontSize(displayValue.length);

    return ShaderMask(
      shaderCallback: (bounds) {
        if (useGradient && !isError && displayValue != '0') {
          return AppTheme.primaryGradient.createShader(bounds);
        }
        return LinearGradient(
          colors: [
            isError ? AppTheme.deleteColor : AppTheme.textPrimary,
            isError ? AppTheme.deleteColor : AppTheme.textPrimary,
          ],
        ).createShader(bounds);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(displayValue.length, (i) {
          final char = displayValue[i];
          final isDigit = '0123456789'.contains(char);

          if (isDigit) {
            return _RollingDigit(
              key: ValueKey('digit_$i'),
              digit: int.parse(char),
              fontSize: adaptiveSize,
              index: i,
            );
          } else {
            return _StaticChar(
              key: ValueKey('char_${i}_$char'),
              char: char,
              fontSize: adaptiveSize,
            );
          }
        }),
      ),
    );
  }

  double _computeFontSize(int length) {
    if (length <= 7) return fontSize;
    if (length <= 10) return fontSize * 0.8;
    if (length <= 14) return fontSize * 0.65;
    if (length <= 18) return fontSize * 0.52;
    return fontSize * 0.42;
  }
}

/// A single digit that animates (rolls) when the value changes.
class _RollingDigit extends StatefulWidget {
  final int digit;
  final double fontSize;
  final int index;

  const _RollingDigit({
    super.key,
    required this.digit,
    required this.fontSize,
    required this.index,
  });

  @override
  State<_RollingDigit> createState() => _RollingDigitState();
}

class _RollingDigitState extends State<_RollingDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousDigit = 0;

  @override
  void initState() {
    super.initState();
    _previousDigit = widget.digit;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350 + (widget.index * 30).clamp(0, 150)),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant _RollingDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _previousDigit = oldWidget.digit;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.fontSize * 0.62,
          height: widget.fontSize * 1.15,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Old digit sliding out upward
              Positioned(
                top:
                    widget.fontSize * 0.075 -
                    (_animation.value * widget.fontSize * 1.2),
                child: Opacity(
                  opacity: (1.0 - _animation.value).clamp(0.0, 1.0),
                  child: Text(
                    '$_previousDigit',
                    style: AppTheme.displayLarge.copyWith(
                      fontSize: widget.fontSize,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              // New digit sliding in from below
              Positioned(
                top:
                    widget.fontSize * 0.075 +
                    (widget.fontSize * 1.2 * (1.0 - _animation.value)),
                child: Opacity(
                  opacity: _animation.value.clamp(0.0, 1.0),
                  child: Text(
                    '${widget.digit}',
                    style: AppTheme.displayLarge.copyWith(
                      fontSize: widget.fontSize,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A non-numeric character (., -, e, ∞, etc.) that fades in.
class _StaticChar extends StatefulWidget {
  final String char;
  final double fontSize;

  const _StaticChar({super.key, required this.char, required this.fontSize});

  @override
  State<_StaticChar> createState() => _StaticCharState();
}

class _StaticCharState extends State<_StaticChar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
      child: SizedBox(
        width: widget.char == '.'
            ? widget.fontSize * 0.3
            : widget.fontSize * 0.55,
        height: widget.fontSize * 1.15,
        child: Center(
          child: Text(
            widget.char,
            style: AppTheme.displayLarge.copyWith(
              fontSize: widget.fontSize,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
