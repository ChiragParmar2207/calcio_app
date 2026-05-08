import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A particle that explodes outward from the equals button on press.
class _Particle {
  Offset position;
  Offset velocity;
  double radius;
  double life; // 1.0 → 0.0
  Color color;

  _Particle({
    required this.position,
    required this.velocity,
    required this.radius,
    required this.color,
    this.life = 1.0,
  });
}

class ParticleBurstPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  // ignore: library_private_types_in_public_api
  final List<_Particle> particles;

  ParticleBurstPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final alpha = (p.life * (1.0 - progress)).clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.8)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.radius * 0.5);

      final currentPos = Offset(
        p.position.dx + p.velocity.dx * progress * 2,
        p.position.dy + p.velocity.dy * progress * 2 + (progress * progress * 80), // gravity
      );

      final currentRadius = p.radius * (1.0 - progress * 0.5);
      canvas.drawCircle(currentPos, currentRadius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticleBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// A widget that shows a burst of particles emanating from its center.
/// Call [trigger()] to fire the animation.
class ParticleBurst extends StatefulWidget {
  final Widget child;

  const ParticleBurst({super.key, required this.child});

  @override
  State<ParticleBurst> createState() => ParticleBurstState();
}

class ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_Particle> _particles = [];
  final math.Random _random = math.Random();

  static const _burstColors = [
    Color(0xFF6C63FF),
    Color(0xFFE040FB),
    Color(0xFF00E5FF),
    Color(0xFF64FFDA),
    Color(0xFFFFD740),
    Color(0xFFFF6E40),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void trigger() {
    _generateParticles();
    _controller.forward(from: 0.0);
  }

  void _generateParticles() {
    _particles = List.generate(24, (i) {
      final angle = (i / 24) * math.pi * 2 + _random.nextDouble() * 0.5;
      final speed = 40.0 + _random.nextDouble() * 100;
      return _Particle(
        position: Offset.zero,
        velocity: Offset(
          math.cos(angle) * speed,
          math.sin(angle) * speed,
        ),
        radius: 2.0 + _random.nextDouble() * 4,
        color: _burstColors[_random.nextInt(_burstColors.length)],
        life: 0.6 + _random.nextDouble() * 0.4,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (!_controller.isAnimating && _controller.value == 0) {
              return const SizedBox.shrink();
            }
            return Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: ParticleBurstPainter(
                    progress: _controller.value,
                    particles: _particles,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
