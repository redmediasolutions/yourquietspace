import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

/// The brand mark: a thin ring holding one quiet point of light.
class BrandMark extends StatelessWidget {
  final double size;

  const BrandMark({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BrandPainter()),
    );
  }
}

class _BrandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    canvas.drawCircle(
      c,
      r - 0.75,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = C.text,
    );
    canvas.drawCircle(
      c,
      r * 0.52,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = C.text.withValues(alpha: 0.35),
    );
    canvas.drawCircle(c + Offset(r * 0.52, 0), r * 0.13, Paint()..color = C.accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class Wordmark extends StatelessWidget {
  final double size;

  const Wordmark({super.key, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BrandMark(size: size * 1.6),
        SizedBox(width: size * 0.6),
        Text('Therapist', style: Ty.title.copyWith(fontSize: size + 1, letterSpacing: -0.4)),
      ],
    );
  }
}

/// Orbital system: thin rings, slowly moving points. Used on welcome and matching.
class Orbit extends StatefulWidget {
  final double size;
  final double speed;
  final bool active;
  final Widget? center;

  const Orbit({super.key, this.size = 280, this.speed = 1, this.active = false, this.center});

  @override
  State<Orbit> createState() => _OrbitState();
}

class _OrbitState extends State<Orbit> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 40))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              size: Size.square(widget.size),
              painter: _OrbitPainter(_c.value * widget.speed, widget.active),
            ),
          ),
          if (widget.center != null) widget.center!,
        ],
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double t;
  final bool active;

  _OrbitPainter(this.t, this.active);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final maxR = size.width / 2;
    final rings = [0.36, 0.56, 0.78, 0.98];

    for (var i = 0; i < rings.length; i++) {
      final r = maxR * rings[i];
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: 0.05 + (rings.length - i) * 0.018);
      if (i == 2) {
        // dashed technical ring
        const dashes = 72;
        for (var d = 0; d < dashes; d += 2) {
          final a1 = d / dashes * 2 * math.pi;
          final a2 = (d + 1) / dashes * 2 * math.pi;
          canvas.drawArc(Rect.fromCircle(center: c, radius: r), a1, a2 - a1, false, ring);
        }
      } else {
        canvas.drawCircle(c, r, ring);
      }
    }

    // tick marks on the outer ring
    final tick = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.12);
    for (var k = 0; k < 48; k++) {
      final a = k / 48 * 2 * math.pi;
      final len = k % 4 == 0 ? 6.0 : 3.0;
      final r1 = maxR * 0.98;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * r1,
        c + Offset(math.cos(a), math.sin(a)) * (r1 - len),
        tick,
      );
    }

    // orbiting points
    final speedMul = active ? 3.0 : 1.0;
    final bodies = [
      (rings[0], 1.0, 3.0, C.accent, 0.0),
      (rings[1], -0.7, 2.2, C.text, 1.7),
      (rings[2], 0.45, 2.6, C.text, 3.4),
      (rings[3], -0.3, 1.8, C.accent, 4.9),
    ];
    for (final (rf, sp, rad, color, phase) in bodies) {
      final a = phase + t * 2 * math.pi * sp * speedMul * 6;
      final p = c + Offset(math.cos(a), math.sin(a)) * (maxR * rf);
      canvas.drawCircle(p, rad * 3.5, Paint()..color = color.withValues(alpha: 0.08));
      canvas.drawCircle(p, rad, Paint()..color = color.withValues(alpha: 0.9));
    }

    // centre crosshair
    final cross = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.1);
    canvas.drawLine(c - const Offset(8, 0), c + const Offset(8, 0), cross);
    canvas.drawLine(c - const Offset(0, 8), c + const Offset(0, 8), cross);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter old) => old.t != t || old.active != active;
}

/// Privacy visual: a lock drawn in hairlines over a dot field, with a slow scan line.
class LockMark extends StatefulWidget {
  final double size;

  const LockMark({super.key, this.size = 170});

  @override
  State<LockMark> createState() => _LockMarkState();
}

class _LockMarkState extends State<LockMark> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => CustomPaint(size: Size.square(widget.size), painter: _LockPainter(_c.value)),
    );
  }
}

class _LockPainter extends CustomPainter {
  final double t;

  _LockPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final c = size.center(Offset.zero);

    // dot field inside a circle
    final dot = Paint();
    const step = 9.0;
    for (double y = step / 2; y < w; y += step) {
      for (double x = step / 2; x < w; x += step) {
        final d = (Offset(x, y) - c).distance;
        if (d > w / 2 - 4) continue;
        final scanY = t * w;
        final near = (1 - ((y - scanY).abs() / 26)).clamp(0.0, 1.0);
        dot.color = Color.lerp(Colors.white.withValues(alpha: 0.07), C.accent.withValues(alpha: 0.6), near * 0.8)!;
        canvas.drawCircle(Offset(x, y), 0.9, dot);
      }
    }

    // outer ring
    canvas.drawCircle(
      c,
      w / 2 - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = C.border,
    );

    // lock body
    final bodyW = w * 0.34;
    final bodyH = w * 0.27;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c + Offset(0, w * 0.07), width: bodyW, height: bodyH),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(body, Paint()..color = C.bg);
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = C.text,
    );

    // shackle
    final shackleR = bodyW * 0.3;
    final top = body.top;
    final path = Path()
      ..moveTo(c.dx - shackleR, top)
      ..lineTo(c.dx - shackleR, top - shackleR * 0.55)
      ..arcToPoint(Offset(c.dx + shackleR, top - shackleR * 0.55), radius: Radius.circular(shackleR))
      ..lineTo(c.dx + shackleR, top);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = C.text,
    );

    // keyhole as accent point
    canvas.drawCircle(body.center - const Offset(0, 2), 3, Paint()..color = C.accent);
    canvas.drawLine(
      body.center + const Offset(0, 1),
      body.center + const Offset(0, 8),
      Paint()
        ..strokeWidth = 1.4
        ..color = C.accent
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _LockPainter old) => old.t != t;
}

/// Thin stepped progress used during onboarding.
class StepBar extends StatelessWidget {
  final int step;
  final int total;

  const StepBar({super.key, required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('${step.toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}', style: Ty.mono(color: C.text3)),
        const SizedBox(width: 14),
        Expanded(
          child: Row(
            children: List.generate(total, (i) {
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 2,
                  margin: EdgeInsets.only(right: i == total - 1 ? 0 : 4),
                  decoration: BoxDecoration(
                    color: i < step ? C.text : C.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
