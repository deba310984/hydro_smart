import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'krishi_theme.dart';

/// Warli Art CustomPainter
/// Creates authentic Indian tribal art patterns as watermarks
/// Traditional Warli art uses white on terracotta backgrounds
class WarliPainter extends CustomPainter {
  final double opacity;
  final Color color;
  final WarliPattern pattern;

  WarliPainter({
    this.opacity = 0.04,
    this.color = KrishiTheme.primaryGreen,
    this.pattern = WarliPattern.farmer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    switch (pattern) {
      case WarliPattern.farmer:
        _drawFarmer(canvas, size, paint);
        break;
      case WarliPattern.crops:
        _drawCrops(canvas, size, paint);
        break;
      case WarliPattern.sun:
        _drawSun(canvas, size, paint);
        break;
      case WarliPattern.village:
        _drawVillage(canvas, size, paint);
        break;
      case WarliPattern.mandala:
        _drawMandala(canvas, size, paint);
        break;
    }
  }

  /// Draw a traditional Warli farmer figure
  void _drawFarmer(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width * 0.85;
    final centerY = size.height * 0.2;
    final scale = size.width * 0.15;

    // Head (triangle)
    final headPath = Path()
      ..moveTo(centerX, centerY - scale * 0.4)
      ..lineTo(centerX - scale * 0.15, centerY - scale * 0.2)
      ..lineTo(centerX + scale * 0.15, centerY - scale * 0.2)
      ..close();
    canvas.drawPath(headPath, paint);

    // Body (triangle)
    final bodyPath = Path()
      ..moveTo(centerX, centerY - scale * 0.15)
      ..lineTo(centerX - scale * 0.2, centerY + scale * 0.15)
      ..lineTo(centerX + scale * 0.2, centerY + scale * 0.15)
      ..close();
    canvas.drawPath(bodyPath, paint);

    // Arms
    canvas.drawLine(
      Offset(centerX - scale * 0.15, centerY),
      Offset(centerX - scale * 0.35, centerY - scale * 0.1),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + scale * 0.15, centerY),
      Offset(centerX + scale * 0.35, centerY - scale * 0.15),
      paint,
    );

    // Legs
    canvas.drawLine(
      Offset(centerX - scale * 0.1, centerY + scale * 0.15),
      Offset(centerX - scale * 0.15, centerY + scale * 0.4),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + scale * 0.1, centerY + scale * 0.15),
      Offset(centerX + scale * 0.15, centerY + scale * 0.4),
      paint,
    );

    // Farming tool (hoe)
    canvas.drawLine(
      Offset(centerX + scale * 0.35, centerY - scale * 0.15),
      Offset(centerX + scale * 0.5, centerY + scale * 0.2),
      paint,
    );
    canvas.drawLine(
      Offset(centerX + scale * 0.5, centerY + scale * 0.2),
      Offset(centerX + scale * 0.35, centerY + scale * 0.25),
      paint,
    );
  }

  /// Draw crop/plant motifs
  void _drawCrops(Canvas canvas, Size size, Paint paint) {
    final baseX = size.width * 0.8;
    final baseY = size.height * 0.85;
    final scale = size.width * 0.1;

    // Main stem
    final stemPath = Path()
      ..moveTo(baseX, baseY)
      ..quadraticBezierTo(
        baseX + scale * 0.1,
        baseY - scale * 0.5,
        baseX,
        baseY - scale,
      );
    canvas.drawPath(stemPath, paint);

    // Leaves
    for (int i = 0; i < 3; i++) {
      final leafY = baseY - scale * (0.3 + i * 0.25);
      final direction = i.isEven ? 1 : -1;

      // Leaf shape
      final leafPath = Path()
        ..moveTo(baseX, leafY)
        ..quadraticBezierTo(
          baseX + direction * scale * 0.3,
          leafY - scale * 0.1,
          baseX + direction * scale * 0.2,
          leafY + scale * 0.05,
        );
      canvas.drawPath(leafPath, paint);
    }

    // Grain/seed at top
    canvas.drawCircle(
      Offset(baseX, baseY - scale * 1.1),
      scale * 0.08,
      paint,
    );
  }

  /// Draw sun motif
  void _drawSun(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width * 0.15;
    final centerY = size.height * 0.15;
    final radius = size.width * 0.08;

    // Central circle
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // Sun rays
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * math.pi / 180;
      final startX = centerX + math.cos(angle) * radius * 1.2;
      final startY = centerY + math.sin(angle) * radius * 1.2;
      final endX = centerX + math.cos(angle) * radius * 1.6;
      final endY = centerY + math.sin(angle) * radius * 1.6;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  /// Draw village hut
  void _drawVillage(Canvas canvas, Size size, Paint paint) {
    final baseX = size.width * 0.1;
    final baseY = size.height * 0.9;
    final scale = size.width * 0.12;

    // Hut base (rectangle)
    canvas.drawRect(
      Rect.fromLTWH(
        baseX - scale * 0.4,
        baseY - scale * 0.4,
        scale * 0.8,
        scale * 0.4,
      ),
      paint,
    );

    // Roof (triangle)
    final roofPath = Path()
      ..moveTo(baseX, baseY - scale * 0.8)
      ..lineTo(baseX - scale * 0.5, baseY - scale * 0.4)
      ..lineTo(baseX + scale * 0.5, baseY - scale * 0.4)
      ..close();
    canvas.drawPath(roofPath, paint);

    // Door
    canvas.drawRect(
      Rect.fromLTWH(
        baseX - scale * 0.1,
        baseY - scale * 0.3,
        scale * 0.2,
        scale * 0.3,
      ),
      paint,
    );
  }

  /// Draw mandala pattern
  void _drawMandala(Canvas canvas, Size size, Paint paint) {
    final centerX = size.width * 0.9;
    final centerY = size.height * 0.1;
    final maxRadius = size.width * 0.12;

    // Concentric circles
    for (int i = 1; i <= 3; i++) {
      final radius = maxRadius * i / 3;
      canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    }

    // Petals
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180;
      final innerRadius = maxRadius * 0.35;
      final outerRadius = maxRadius * 0.7;

      // Petal shape
      final startX = centerX + math.cos(angle) * innerRadius;
      final startY = centerY + math.sin(angle) * innerRadius;
      final endX = centerX + math.cos(angle) * outerRadius;
      final endY = centerY + math.sin(angle) * outerRadius;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // Petal circles
      canvas.drawCircle(
        Offset(endX, endY),
        maxRadius * 0.08,
        paint,
      );
    }

    // Center dot
    canvas.drawCircle(
      Offset(centerX, centerY),
      maxRadius * 0.1,
      paint..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant WarliPainter oldDelegate) =>
      opacity != oldDelegate.opacity ||
      color != oldDelegate.color ||
      pattern != oldDelegate.pattern;
}

/// Available Warli art patterns
enum WarliPattern {
  farmer,
  crops,
  sun,
  village,
  mandala,
}

/// A widget that displays Warli art as a background decoration
class WarliBackground extends StatelessWidget {
  final Widget child;
  final WarliPattern pattern;
  final double opacity;
  final Color? color;

  const WarliBackground({
    super.key,
    required this.child,
    this.pattern = WarliPattern.farmer,
    this.opacity = 0.04,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WarliPainter(
        pattern: pattern,
        opacity: opacity,
        color: color ?? KrishiTheme.primaryGreen,
      ),
      child: child,
    );
  }
}

/// Multi-pattern Warli decoration for dashboard cards
class WarliDecoratedCard extends StatelessWidget {
  final Widget child;
  final List<WarliPattern> patterns;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const WarliDecoratedCard({
    super.key,
    required this.child,
    this.patterns = const [WarliPattern.farmer, WarliPattern.crops],
    this.opacity = 0.03,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    // Apply multiple patterns
    for (final pattern in patterns) {
      content = WarliBackground(
        pattern: pattern,
        opacity: opacity,
        child: content,
      );
    }

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KrishiTheme.radiusLarge),
        boxShadow: KrishiTheme.cardShadow,
      ),
      child: content,
    );
  }
}
