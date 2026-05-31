import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ilustraciones de marca para estados vacíos, dibujadas por código.
///
/// Arte 100% propio (sin assets con copyright) y adaptativo: todos los colores
/// salen del [ColorScheme] activo, así funciona en claro y oscuro y respeta la
/// paleta elegida por el usuario. Motivo común: moneda "$" + chispa de estrella,
/// alineado con el icono de la app (estrella fugaz con monedas).
enum EmptyArt { transactions, services, categories, history, chart }

class BrandEmptyArt extends StatelessWidget {
  const BrandEmptyArt(this.kind, {super.key, this.size = 124});

  final EmptyArt kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EmptyArtPainter(kind, Theme.of(context).colorScheme),
      ),
    );
  }
}

class _EmptyArtPainter extends CustomPainter {
  _EmptyArtPainter(this.kind, this.scheme);

  final EmptyArt kind;
  final ColorScheme scheme;

  // Dorado de las monedas (ata con el icono); legible en claro y oscuro.
  static const _gold = Color(0xFFF59E0B);

  // Lienzo base de diseño: 124x124 (se escala al tamaño real).
  static const _unit = 124.0;

  Paint get _stroke => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..color = scheme.primary;

  Paint get _fill => Paint()..color = scheme.surface;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _unit);

    // Fondo suave circular (mismo lenguaje que el EmptyStateView original).
    canvas.drawCircle(
      const Offset(62, 62),
      56,
      Paint()..color = scheme.primaryContainer.withValues(alpha: 0.35),
    );

    switch (kind) {
      case EmptyArt.transactions:
        _wallet(canvas);
      case EmptyArt.services:
        _calendar(canvas);
      case EmptyArt.categories:
        _tags(canvas);
      case EmptyArt.history:
        _clock(canvas);
      case EmptyArt.chart:
        _bars(canvas);
    }

    // Chispa de estrella común (sello de marca).
    _sparkle(canvas, const Offset(95, 35), 9);
  }

  // --- Motivos ------------------------------------------------------------

  void _wallet(Canvas c) {
    // moneda asomando por detrás de la billetera
    _coin(c, const Offset(74, 46), 13);
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(28, 52, 60, 34),
      const Radius.circular(10),
    );
    c.drawRRect(body, _fill);
    c.drawRRect(body, _stroke);
    // broche
    c.drawCircle(const Offset(78, 69), 4.5, Paint()..color = _gold);
    c.drawCircle(const Offset(78, 69), 4.5, _stroke);
  }

  void _calendar(Canvas c) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(32, 44, 60, 50),
      const Radius.circular(10),
    );
    c.drawRRect(body, _fill);
    c.drawRRect(body, _stroke);
    c.drawLine(const Offset(32, 61), const Offset(92, 61), _stroke);
    c.drawLine(const Offset(46, 40), const Offset(46, 50), _stroke);
    c.drawLine(const Offset(78, 40), const Offset(78, 50), _stroke);
    final dot = Paint()..color = scheme.primary.withValues(alpha: 0.35);
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 3; col++) {
        c.drawCircle(Offset(45 + col * 13.0, 73 + row * 12.0), 3, dot);
      }
    }
    // un día marcado como moneda
    _coin(c, const Offset(81, 85), 9);
  }

  void _tags(Canvas c) {
    _tag(c, const Offset(57, 71), -0.32, scheme.primary.withValues(alpha: 0.85));
    _tag(c, const Offset(67, 54), -0.32, _gold);
  }

  void _tag(Canvas c, Offset o, double angle, Color color) {
    c.save();
    c.translate(o.dx, o.dy);
    c.rotate(angle);
    final path = Path()
      ..moveTo(-22, -12)
      ..lineTo(8, -12)
      ..lineTo(22, 0)
      ..lineTo(8, 12)
      ..lineTo(-22, 12)
      ..close();
    c.drawPath(path, Paint()..color = color);
    c.drawPath(path, _stroke);
    c.drawCircle(const Offset(9, 0), 3.5, _fill);
    c.restore();
  }

  void _clock(Canvas c) {
    const o = Offset(57, 60);
    c.drawCircle(o, 26, _fill);
    c.drawCircle(o, 26, _stroke);
    c.drawLine(o, o.translate(0, -14), _stroke);
    c.drawLine(o, o.translate(11, 4), _stroke);
    _coin(c, const Offset(86, 86), 10);
  }

  void _bars(Canvas c) {
    const base = 90.0;
    const heights = [16.0, 26.0, 38.0, 50.0];
    for (var i = 0; i < heights.length; i++) {
      final r = RRect.fromRectAndRadius(
        Rect.fromLTWH(36 + i * 14.0, base - heights[i], 9, heights[i]),
        const Radius.circular(3),
      );
      c.drawRRect(
        r,
        Paint()
          ..color = i.isOdd ? _gold : scheme.primary.withValues(alpha: 0.85),
      );
    }
    c.drawLine(const Offset(30, base), const Offset(96, base), _stroke);
  }

  // --- Primitivas ---------------------------------------------------------

  void _coin(Canvas c, Offset o, double r) {
    c.drawCircle(o, r, Paint()..color = _gold);
    c.drawCircle(
      o,
      r * 0.74,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.16
        ..color = scheme.primary,
    );
    _glyph(c, o, r * 1.35);
  }

  /// Dibuja un "$" centrado en [o] (tamaño tipográfico [fontSize]).
  void _glyph(Canvas c, Offset o, double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: r'$',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: scheme.primary,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, o - Offset(tp.width / 2, tp.height / 2));
  }

  void _sparkle(Canvas c, Offset o, double r) {
    final p = Path();
    for (var i = 0; i < 8; i++) {
      final rad = i.isEven ? r : r * 0.4;
      final a = -math.pi / 2 + i * math.pi / 4;
      final pt = o + Offset(rad * math.cos(a), rad * math.sin(a));
      i == 0 ? p.moveTo(pt.dx, pt.dy) : p.lineTo(pt.dx, pt.dy);
    }
    p.close();
    c.drawPath(p, Paint()..color = _gold);
  }

  @override
  bool shouldRepaint(covariant _EmptyArtPainter old) =>
      old.kind != kind || old.scheme != scheme;
}
