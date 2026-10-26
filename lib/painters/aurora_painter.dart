import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A living, breathing aurora/mesh-gradient background painted with CustomPainter.
/// Uses layered sine waves with shifting phases to create organic flowing color bands.
class AuroraPainter extends CustomPainter {
  final double time;
  final List<Color> colors;

  AuroraPainter({required this.time, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw 5 layered aurora ribbons
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final color = colors[i % colors.length];

      // Each ribbon has unique frequency, amplitude, and phase
      final freq = 0.003 + (i * 0.001);
      final amp = size.height * (0.06 + i * 0.02);
      final phase = time * (0.5 + i * 0.15) + i * math.pi / 3;
      final yBase = size.height * (0.15 + i * 0.15);

      path.moveTo(0, size.height);
      path.lineTo(0, yBase + math.sin(phase) * amp);

      // Create smooth sine-based curve across the width
      for (double x = 0; x <= size.width; x += 4) {
        final y =
            yBase +
            math.sin(x * freq + phase) * amp +
            math.sin(x * freq * 2.3 + phase * 1.5) * (amp * 0.3) +
            math.cos(x * freq * 0.7 + phase * 0.8) * (amp * 0.2);
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.close();

      paint.shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: 0.06 + (i * 0.01)),
          color.withValues(alpha: 0.02),
          color.withValues(alpha: 0.04 + (i * 0.005)),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(path, paint);
    }

    // Add subtle radial glow spots that drift
    _drawGlowSpot(
      canvas,
      size,
      Offset(
        size.width * (0.2 + 0.3 * math.sin(time * 0.3)),
        size.height * (0.25 + 0.1 * math.cos(time * 0.4)),
      ),
      colors[0].withValues(alpha: 0.05),
      size.width * 0.4,
    );

    _drawGlowSpot(
      canvas,
      size,
      Offset(
        size.width * (0.7 + 0.2 * math.cos(time * 0.25)),
        size.height * (0.5 + 0.15 * math.sin(time * 0.35)),
      ),
      colors[2].withValues(alpha: 0.04),
      size.width * 0.35,
    );

    _drawGlowSpot(
      canvas,
      size,
      Offset(
        size.width * (0.5 + 0.25 * math.sin(time * 0.2 + 1)),
        size.height * (0.7 + 0.1 * math.cos(time * 0.3 + 2)),
      ),
      colors[3].withValues(alpha: 0.035),
      size.width * 0.3,
    );
  }

  void _drawGlowSpot(
    Canvas canvas,
    Size size,
    Offset center,
    Color color,
    double radius,
  ) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) => oldDelegate.time != time;
}

/// Widget wrapper for the aurora background.
class AnimatedAuroraBackground extends StatefulWidget {
  const AnimatedAuroraBackground({super.key});

  @override
  State<AnimatedAuroraBackground> createState() =>
      _AnimatedAuroraBackgroundState();
}

class _AnimatedAuroraBackgroundState extends State<AnimatedAuroraBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;

  static const _auroraColors = [
    Color(0xFF6C63FF), // Indigo
    Color(0xFFE040FB), // Pink
    Color(0xFF00E5FF), // Cyan
    Color(0xFF64FFDA), // Teal
    Color(0xFFFF6E40), // Deep Orange
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause animation when app is backgrounded to save battery
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _controller.stop();
    } else if (state == AppLifecycleState.resumed) {
      _controller.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: AuroraPainter(
            time:
                _controller.value *
                math.pi *
                2 *
                3, // 3 full cycles over duration
            colors: _auroraColors,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}
