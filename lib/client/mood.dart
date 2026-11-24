import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

/// Abstract mood mark: brightness and size of the core grow with the value.
class MoodOrb extends StatelessWidget {
  final int value; // 0..4
  final double size;
  final bool dim;

  const MoodOrb({super.key, required this.value, this.size = 44, this.dim = false});

  @override
  Widget build(BuildContext context) {
    final t = value / 4;
    final core = size * (0.22 + 0.2 * t);
    final color = Color.lerp(const Color(0xFF6B7280), C.accent, dim ? 0.2 : 0.35 + 0.65 * t)!;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: C.border),
              gradient: RadialGradient(colors: [color.withValues(alpha: dim ? 0.06 : 0.12 + 0.18 * t), Colors.transparent]),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            width: core,
            height: core,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dim ? C.text4 : color,
              boxShadow: dim ? null : [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: size * 0.25)],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── 14. Check-in ─────────────────────────────

class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  double _pos = 2; // continuous while dragging, snapped on release
  bool _touched = false;
  final _note = TextEditingController();
  final Set<String> _tags = {};
  bool _saved = false;

  static const tags = ['Work', 'Sleep', 'People', 'Health', 'Family', 'Nothing specific'];

  int get _value => _pos.round().clamp(0, 4);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final note = [if (_tags.isNotEmpty) _tags.join(', '), if (_note.text.trim().isNotEmpty) _note.text.trim()].join(' — ');
    app.addMood(_value, note.isEmpty ? null : note);
    setState(() => _saved = true);
    await Future.delayed(const Duration(milliseconds: 1300));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final orb = math.min(MediaQuery.sizeOf(context).width * 0.62, 260.0);
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _saved
                ? _SavedState(value: _value, key: const ValueKey('s'))
                : Column(
                    key: const ValueKey('f'),
                    children: [
                      TopBar(backIcon: Icons.close_rounded, titleWidget: Label(fmtDate(DateTime.now()))),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                          children: [
                            Text('How are you feeling\nright now?', textAlign: TextAlign.center, style: Ty.h1),
                            const SizedBox(height: 28),
                            Center(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(end: _pos / 4),
                                duration: const Duration(milliseconds: 260),
                                curve: Curves.easeOut,
                                builder: (_, t, __) => _BigOrb(size: orb, t: t),
                              ),
                            ),
                            const SizedBox(height: 22),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: Text(
                                _touched ? moodLabels[_value] : 'Slide to choose',
                                key: ValueKey(_touched ? _value : -1),
                                textAlign: TextAlign.center,
                                style: Ty.h2.copyWith(color: _touched ? C.text : C.text3),
                              ),
                            ),
                            const SizedBox(height: 22),
                            _MoodDial(
                              pos: _pos,
                              onChanged: (v) => setState(() {
                                _pos = v;
                                _touched = true;
                              }),
                              onEnd: () => setState(() => _pos = _value.toDouble()),
                            ),
                            const SizedBox(height: 32),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: _touched ? 1 : 0.35,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Label('What\'s connected to it? · optional'),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: tags
                                        .map((t) => ChoiceChipX(
                                              label: t,
                                              selected: _tags.contains(t),
                                              onTap: () => setState(() => _tags.contains(t) ? _tags.remove(t) : _tags.add(t)),
                                            ))
                                        .toList(),
                                  ),
                                  const SizedBox(height: 20),
                                  Field(controller: _note, hint: 'Add a note for yourself', maxLines: 2),
                                  const SizedBox(height: 10),
                                  Text('Check-ins are private. Your therapist sees them only if you choose to share.', style: Ty.tiny),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                        child: Btn('Save check-in', onTap: _touched ? _save : null),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _BigOrb extends StatelessWidget {
  final double size;
  final double t;

  const _BigOrb({required this.size, required this.t});

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(const Color(0xFF6B7280), C.accent, 0.3 + 0.7 * t)!;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 4; i++)
            Container(
              width: size * (0.5 + i * 0.165),
              height: size * (0.5 + i * 0.165),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.03 + (t * 0.05) * (4 - i) / 4)),
              ),
            ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [color.withValues(alpha: 0.1 + 0.22 * t), color.withValues(alpha: 0)]),
            ),
          ),
          Container(
            width: size * (0.2 + 0.18 * t),
            height: size * (0.2 + 0.18 * t),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color.lerp(color, Colors.white, 0.35)!, color]),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35 + 0.3 * t), blurRadius: 40 + 40 * t)],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodDial extends StatelessWidget {
  final double pos;
  final ValueChanged<double> onChanged;
  final VoidCallback onEnd;

  const _MoodDial({required this.pos, required this.onChanged, required this.onEnd});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, box) {
        const pad = 14.0;
        final w = box.maxWidth - pad * 2;
        double toPos(double dx) => ((dx - pad) / w * 4).clamp(0.0, 4.0);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => onChanged(toPos(d.localPosition.dx)),
          onTapUp: (_) => onEnd(),
          onHorizontalDragUpdate: (d) => onChanged(toPos(d.localPosition.dx)),
          onHorizontalDragEnd: (_) => onEnd(),
          child: SizedBox(
            height: 64,
            child: Stack(
              children: [
                // track
                Positioned(
                  left: pad,
                  right: pad,
                  top: 13,
                  child: Container(height: 2, decoration: BoxDecoration(color: C.border, borderRadius: BorderRadius.circular(2))),
                ),
                Positioned(
                  left: pad,
                  top: 13,
                  child: Container(
                    width: w * pos / 4,
                    height: 2,
                    decoration: BoxDecoration(color: C.accentA(0.7), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                // stops + labels
                for (var i = 0; i < 5; i++)
                  Positioned(
                    left: pad + w * i / 4 - 30,
                    top: 0,
                    width: 60,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i <= pos.round() ? C.accent : C.bg,
                            border: Border.all(color: i <= pos.round() ? C.accent : C.border, width: 1.5),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          moodLabels[i],
                          textAlign: TextAlign.center,
                          style: Ty.mono(size: 8.5, color: i == pos.round() ? C.text : C.text4, ls: 0.6),
                        ),
                      ],
                    ),
                  ),
                // thumb
                Positioned(
                  left: pad + w * pos / 4 - 13,
                  top: 1,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: C.text,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SavedState extends StatelessWidget {
  final int value;

  const _SavedState({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.6, end: 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutBack,
            builder: (_, s, child) => Transform.scale(scale: s, child: child),
            child: MoodOrb(value: value, size: 96),
          ),
          const SizedBox(height: 24),
          Text('Check-in saved.', style: Ty.h2),
          const SizedBox(height: 6),
          Text('Noticing is a step in itself.', style: Ty.small),
        ],
      ),
    );
  }
}

// ───────────────────────────── 15. Mood history ─────────────────────────────

class MoodHistoryScreen extends StatefulWidget {
  const MoodHistoryScreen({super.key});

  @override
  State<MoodHistoryScreen> createState() => _MoodHistoryScreenState();
}

class _MoodHistoryScreenState extends State<MoodHistoryScreen> {
  int _range = 0; // 0 = 7d, 1 = 30d

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final days = _range == 0 ? 7 : 30;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final series = List<int?>.generate(days, (i) {
          final d = today.subtract(Duration(days: days - 1 - i));
          int? v;
          for (final m in app.moods) {
            if (m.at.year == d.year && m.at.month == d.month && m.at.day == d.day) v = m.value;
          }
          return v;
        });
        final logged = series.whereType<int>().toList();

        return SafeArea(
          child: Narrow(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Mood', style: Ty.h1)),
                    Btn(
                      'Check in',
                      icon: Icons.add_rounded,
                      expand: false,
                      height: 40,
                      kind: BtnKind.secondary,
                      onTap: () => Navigator.of(context).push(fade(const MoodCheckInScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Segmented(items: const ['7 days', '30 days'], index: _range, onChanged: (i) => setState(() => _range = i)),
                const SizedBox(height: 24),
                Surface(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_range == 0 ? 'Your week' : 'Your month', style: Ty.h2),
                      const SizedBox(height: 6),
                      Text(_insight(series), style: Ty.small),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 170,
                        child: logged.isEmpty
                            ? Center(child: Text('No check-ins in this period yet', style: Ty.tiny))
                            : TweenAnimationBuilder<double>(
                                key: ValueKey(_range),
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                builder: (_, p, __) => CustomPaint(
                                  size: Size.infinite,
                                  painter: _MoodChart(series, p, today, showDays: _range == 0),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _Stat(label: 'Check-ins', value: '${logged.length}', sub: 'of $days days')),
                    const SizedBox(width: 12),
                    Expanded(child: _Stat(label: 'Most often', value: logged.isEmpty ? '—' : moodLabels[_mode(logged)], sub: 'this period')),
                  ],
                ),
                const SizedBox(height: 28),
                const SectionTitle('Recent check-ins'),
                if (app.moods.isEmpty)
                  const EmptyState(
                    icon: Icons.waves,
                    title: 'No check-ins yet',
                    body: 'A quick check-in each day helps you notice patterns over time.',
                  )
                else
                  Group(
                    children: app.moods.reversed.take(6).map((m) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MoodOrb(value: m.value, size: 34),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(moodLabels[m.value], style: Ty.bodyStrong.copyWith(fontSize: 14.5, height: 1.3)),
                                      const Spacer(),
                                      Text('${fmtRelativeDay(m.at)} · ${fmtTime(m.at)}', style: Ty.mono(size: 9.5, color: C.text4, ls: 0.3)),
                                    ],
                                  ),
                                  if (m.note != null) ...[
                                    const SizedBox(height: 4),
                                    Text(m.note!, style: Ty.small.copyWith(fontSize: 13)),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 18),
                Text(
                  'These reflections are based only on your own check-ins. They\'re not a medical assessment.',
                  textAlign: TextAlign.center,
                  style: Ty.tiny.copyWith(color: C.text4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _mode(List<int> xs) {
    final counts = List.filled(5, 0);
    for (final x in xs) {
      counts[x]++;
    }
    var best = 0;
    for (var i = 1; i < 5; i++) {
      if (counts[i] > counts[best]) best = i;
    }
    return best;
  }

  String _insight(List<int?> s) {
    final xs = s.whereType<int>().toList();
    if (xs.length < 3) return 'Check in a few more times and patterns will start to appear here.';
    final recent = xs.sublist(xs.length - 3);
    final earlier = xs.sublist(0, xs.length - 3);
    if (earlier.isEmpty) return 'Things have felt fairly steady lately.';
    double avg(List<int> l) => l.reduce((a, b) => a + b) / l.length;
    final d = avg(recent) - avg(earlier);
    if (d > 0.3) return 'You\'ve felt more settled over the last few days.';
    if (d < -0.3) return 'The last few days seem to have felt heavier. That\'s okay — it may be worth mentioning in your conversation.';
    return 'Things have felt fairly steady lately.';
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;

  const _Stat({required this.label, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Surface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(label),
          const SizedBox(height: 10),
          Text(value, style: Ty.h2.copyWith(fontSize: 19)),
          const SizedBox(height: 2),
          Text(sub, style: Ty.tiny),
        ],
      ),
    );
  }
}

class _MoodChart extends CustomPainter {
  final List<int?> s;
  final double p;
  final DateTime today;
  final bool showDays;

  _MoodChart(this.s, this.p, this.today, {required this.showDays});

  @override
  void paint(Canvas canvas, Size size) {
    const left = 0.0;
    const bottomPad = 22.0;
    final h = size.height - bottomPad;
    final w = size.width - left;
    final n = s.length;
    double x(int i) => left + (n == 1 ? w / 2 : w * i / (n - 1));
    double y(int v) => h - (v / 4) * (h - 12) - 6;

    // horizontal guides
    final guide = Paint()
      ..color = C.hairline
      ..strokeWidth = 1;
    for (var v = 0; v <= 4; v += 2) {
      final yy = y(v);
      for (double xx = 0; xx < size.width; xx += 6) {
        canvas.drawLine(Offset(xx, yy), Offset(xx + 2, yy), guide);
      }
    }

    // line through logged points
    final pts = <Offset>[];
    for (var i = 0; i < n; i++) {
      final v = s[i];
      if (v != null) pts.add(Offset(x(i), h - (h - y(v)) * p));
    }
    if (pts.length > 1) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 1; i < pts.length; i++) {
        final a = pts[i - 1];
        final b = pts[i];
        final mx = (a.dx + b.dx) / 2;
        path.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
      }
      final area = Path.from(path)
        ..lineTo(pts.last.dx, h)
        ..lineTo(pts.first.dx, h)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [C.accent.withValues(alpha: 0.14), C.accent.withValues(alpha: 0)],
          ).createShader(Rect.fromLTWH(0, 0, size.width, h)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = C.accent.withValues(alpha: 0.85),
      );
    }

    // points + day labels
    for (var i = 0; i < n; i++) {
      final v = s[i];
      final cx = x(i);
      if (v != null) {
        final cy = h - (h - y(v)) * p;
        canvas.drawCircle(Offset(cx, cy), showDays ? 3.5 : 2.2, Paint()..color = C.bg);
        canvas.drawCircle(
          Offset(cx, cy),
          showDays ? 3.5 : 2.2,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = C.accent,
        );
      } else if (showDays) {
        canvas.drawCircle(Offset(cx, h - 2), 1.5, Paint()..color = C.text4);
      }
      final labelEvery = showDays ? 1 : 7;
      if ((n - 1 - i) % labelEvery == 0) {
        final d = today.subtract(Duration(days: n - 1 - i));
        final txt = showDays ? fmtDay(d).substring(0, 1) : '${d.day}/${d.month}';
        final tp = TextPainter(
          text: TextSpan(text: txt, style: Ty.mono(size: 9, color: i == n - 1 ? C.text : C.text4, ls: 0.4)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset((cx - tp.width / 2).clamp(0.0, size.width - tp.width), size.height - 12));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MoodChart old) => old.p != p || old.s != s;
}
