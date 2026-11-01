import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/weather_helpers.dart';

/// Animated weather background with weather-dependent gradients and effects.
class WeatherBackground extends StatefulWidget {
  final WeatherCondition condition;
  final bool isDarkMode;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.condition,
    required this.isDarkMode,
    required this.child,
  });

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with TickerProviderStateMixin {
  late AnimationController _primaryController;
  late AnimationController _secondaryController;

  @override
  void initState() {
    super.initState();
    _primaryController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _secondaryController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(gradient: _getGradient()),
      child: Stack(
        children: [
          // Weather particles
          if (_shouldAnimate())
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _primaryController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _WeatherParticlePainter(
                      condition: widget.condition,
                      progress: _primaryController.value,
                      secondaryProgress: _secondaryController.value,
                    ),
                  );
                },
              ),
            ),
          widget.child,
        ],
      ),
    );
  }

  bool _shouldAnimate() {
    // Check if reduced motion is preferred
    final mediaQuery = MediaQuery.maybeOf(context);
    if (mediaQuery != null && mediaQuery.disableAnimations) return false;
    return true;
  }

  LinearGradient _getGradient() {
    if (widget.isDarkMode) {
      return _getDarkGradient();
    }
    return _getLightGradient();
  }

  LinearGradient _getLightGradient() {
    switch (widget.condition) {
      case WeatherCondition.sunny:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4FC3F7), Color(0xFF0288D1), Color(0xFF01579B)],
          stops: [0.0, 0.5, 1.0],
        );
      case WeatherCondition.cloudy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF90A4AE), Color(0xFF607D8B), Color(0xFF455A64)],
          stops: [0.0, 0.5, 1.0],
        );
      case WeatherCondition.rainy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF37474F), Color(0xFF263238), Color(0xFF1A237E)],
          stops: [0.0, 0.5, 1.0],
        );
      case WeatherCondition.snowy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBBDEFB), Color(0xFF90CAF9), Color(0xFF64B5F6)],
          stops: [0.0, 0.5, 1.0],
        );
      case WeatherCondition.stormy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          stops: [0.0, 0.5, 1.0],
        );
      case WeatherCondition.night:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF1B3A4B)],
          stops: [0.0, 0.5, 1.0],
        );
    }
  }

  LinearGradient _getDarkGradient() {
    switch (widget.condition) {
      case WeatherCondition.sunny:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF1B3A4B)],
          stops: [0.0, 0.5, 1.0],
        );
      case WeatherCondition.cloudy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          stops: [0.0, 0.5, 1.0],
        );
      case WeatherCondition.rainy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0E1A), Color(0xFF0D1321), Color(0xFF111D2B)],
          stops: [0.0, 0.5, 1.0],
        );
      case WeatherCondition.snowy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1A237E)],
          stops: [0.0, 0.5, 1.0],
        );
      case WeatherCondition.stormy:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0A0A1A), Color(0xFF0D0D24), Color(0xFF12122E)],
          stops: [0.0, 0.5, 1.0],
        );
      case WeatherCondition.night:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF1B3A4B)],
          stops: [0.0, 0.5, 1.0],
        );
    }
  }
}

class _WeatherParticlePainter extends CustomPainter {
  final WeatherCondition condition;
  final double progress;
  final double secondaryProgress;

  _WeatherParticlePainter({
    required this.condition,
    required this.progress,
    required this.secondaryProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (condition) {
      case WeatherCondition.sunny:
        _paintSunRays(canvas, size);
        break;
      case WeatherCondition.rainy:
        _paintRain(canvas, size);
        break;
      case WeatherCondition.snowy:
        _paintSnow(canvas, size);
        break;
      case WeatherCondition.stormy:
        _paintStorm(canvas, size);
        break;
      case WeatherCondition.night:
        _paintStars(canvas, size);
        break;
      case WeatherCondition.cloudy:
        _paintClouds(canvas, size);
        break;
    }
  }

  void _paintSunRays(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.8, size.height * 0.1);
    final maxRadius = size.width * 0.4;

    for (int i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final radius = maxRadius * (0.3 + phase * 0.7);
      final opacity = (1.0 - phase) * 0.15;
      paint.color = Colors.white.withAlpha((opacity * 255).toInt());
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _paintRain(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(60)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rng = Random(42);
    for (int i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final speed = 0.5 + rng.nextDouble() * 0.5;
      final baseY = (progress * speed + rng.nextDouble()) % 1.0;
      final y = baseY * size.height * 1.2 - size.height * 0.1;
      final length = 10 + rng.nextDouble() * 15;

      canvas.drawLine(Offset(x, y), Offset(x - 2, y + length), paint);
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(120)
      ..style = PaintingStyle.fill;

    final rng = Random(42);
    for (int i = 0; i < 30; i++) {
      final baseX = rng.nextDouble() * size.width;
      final speed = 0.3 + rng.nextDouble() * 0.4;
      final baseY = (progress * speed + rng.nextDouble()) % 1.0;
      final y = baseY * size.height;
      final wobble = sin((secondaryProgress + i * 0.1) * pi * 2) * 20;
      final x = baseX + wobble;
      final radius = 2 + rng.nextDouble() * 3;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _paintStorm(Canvas canvas, Size size) {
    // Rain
    _paintRain(canvas, size);

    // Lightning flash effect
    final flashPhase = (progress * 3) % 1.0;
    if (flashPhase < 0.05) {
      final flashPaint = Paint()
        ..color = Colors.white.withAlpha(20)
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), flashPaint);
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final rng = Random(42);
    for (int i = 0; i < 25; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.6;
      final twinkle = (sin((secondaryProgress + i * 0.15) * pi * 2) + 1) / 2;
      final opacity = 0.3 + twinkle * 0.5;
      paint.color = Colors.white.withAlpha((opacity * 255).toInt());
      final radius = 1 + rng.nextDouble() * 1.5;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _paintClouds(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..style = PaintingStyle.fill;

    // Slowly moving cloud shapes
    for (int i = 0; i < 3; i++) {
      final baseX = (progress * 0.3 + i * 0.35) % 1.5 - 0.25;
      final x = baseX * size.width;
      final y = size.height * (0.1 + i * 0.15);
      final w = size.width * (0.3 + i * 0.1);
      final h = 40.0 + i * 10;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(x, y), width: w, height: h),
          Radius.circular(h / 2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherParticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.secondaryProgress != secondaryProgress;
  }
}
