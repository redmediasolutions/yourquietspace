import 'package:flutter/material.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../core/visuals.dart';
import '../core/widgets.dart';
import 'shell.dart';

// ───────────────────────────── 7. Finding a therapist ─────────────────────────────

class FindingScreen extends StatefulWidget {
  /// When true we're finding a *different* therapist (reassignment).
  final bool reassign;

  const FindingScreen({super.key, this.reassign = false});

  @override
  State<FindingScreen> createState() => _FindingScreenState();
}

class _FindingScreenState extends State<FindingScreen> {
  static const steps = ['Understanding your needs', 'Checking availability', 'Finding a match'];
  int _step = 0;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    for (var i = 1; i <= steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1300));
      if (!mounted || _cancelled) return;
      setState(() => _step = i);
    }
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || _cancelled) return;
    final t = widget.reassign
        ? app.therapists.firstWhere((t) => t.id != app.assigned.id && t.presence == Presence.online)
        : app.therapists.first;
    Navigator.of(context).pushReplacement(fade(MatchScreen(therapist: t, reassign: widget.reassign)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: DotGrid(focus: Alignment.center, opacity: 0.06)),
          SafeArea(
            child: Narrow(
              child: Column(
                children: [
                  TopBar(
                    backIcon: Icons.close_rounded,
                    onBack: () {
                      _cancelled = true;
                      Navigator.of(context).pop();
                    },
                  ),
                  const Spacer(),
                  Orbit(
                    size: 260,
                    active: true,
                    center: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.85, end: 1),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeInOut,
                      builder: (_, v, __) => Container(
                        width: 54 * v,
                        height: 54 * v,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: C.bg,
                          border: Border.all(color: C.accentA(0.5)),
                          boxShadow: [BoxShadow(color: C.accentA(0.25), blurRadius: 30)],
                        ),
                        child: Center(child: Text(app.nickname.substring(0, 2), style: Ty.mono(size: 13, color: C.accent))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.reassign ? 'Finding someone new\nwho can help.' : 'Finding someone\nwho can help.',
                      textAlign: TextAlign.center,
                      style: Ty.h1,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: List.generate(steps.length, (i) {
                        final done = i < _step;
                        final current = i == _step;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 18,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: done
                                      ? const Icon(Icons.check_rounded, key: ValueKey('d'), size: 15, color: C.accent)
                                      : current
                                          ? const SizedBox(
                                              key: ValueKey('c'),
                                              width: 11,
                                              height: 11,
                                              child: CircularProgressIndicator(strokeWidth: 1.3, color: C.text2),
                                            )
                                          : Container(
                                              key: const ValueKey('p'),
                                              width: 5,
                                              height: 5,
                                              decoration: const BoxDecoration(color: C.text4, shape: BoxShape.circle),
                                            ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 250),
                                style: Ty.small.copyWith(color: done ? C.text2 : (current ? C.text : C.text4), fontSize: 14),
                                child: Text(steps[i]),
                              ),
                              const Spacer(),
                              Text(done ? 'DONE' : (current ? '···' : ''), style: Ty.mono(size: 9.5, color: C.text4)),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 12, color: C.text4),
                        const SizedBox(width: 6),
                        Text('Matching uses only your nickname and concerns', style: Ty.tiny.copyWith(color: C.text4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── 8. Match result ─────────────────────────────

class MatchScreen extends StatelessWidget {
  final Therapist therapist;
  final bool reassign;

  const MatchScreen({super.key, required this.therapist, this.reassign = false});

  void _start(BuildContext context) {
    app.startFresh(therapist);
    Navigator.of(context).pushAndRemoveUntil(fade(const ClientShell(openChat: true)), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final t = therapist;
    final shared = t.focus.where(app.concerns.contains).toList();
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(top: -160, left: 0, right: 0, child: Center(child: Glow(size: 480, opacity: 0.09))),
          SafeArea(
            child: Narrow(
              child: Column(
                children: [
                  const TopBar(backIcon: Icons.close_rounded),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      children: [
                        const Label('Match found', color: C.accent),
                        const SizedBox(height: 10),
                        Text(reassign ? 'Meet your new\ntherapist.' : 'We found someone\nfor you.', style: Ty.h1),
                        const SizedBox(height: 24),
                        _MatchCard(therapist: t, shared: shared),
                        const SizedBox(height: 16),
                        Surface(
                          padding: const EdgeInsets.all(14),
                          color: C.bg,
                          child: Row(
                            children: [
                              const Icon(Icons.visibility_off_outlined, size: 16, color: C.text3),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(children: [
                                    TextSpan(text: '${t.short} will see you as '),
                                    TextSpan(text: app.nickname, style: Ty.mono(size: 12, color: C.text, ls: 0.3)),
                                    const TextSpan(text: '. Nothing else.'),
                                  ]),
                                  style: Ty.tiny.copyWith(fontSize: 12.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Column(
                      children: [
                        Btn('Start conversation', onTap: () => _start(context)),
                        const SizedBox(height: 8),
                        Btn.ghost(
                          'View profile',
                          onTap: () => Navigator.of(context).push(fade(TherapistProfileScreen(therapist: t, onStart: () => _start(context)))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Therapist therapist;
  final List<String> shared;

  const _MatchCard({required this.therapist, required this.shared});

  @override
  Widget build(BuildContext context) {
    final t = therapist;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 16 * (1 - v)), child: child),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: C.s1,
          borderRadius: BorderRadius.circular(R.lg),
          border: Border.all(color: C.border),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Monogram(t.initials, size: 60, presence: t.presence),
                      const Spacer(),
                      const PrivacyTag(text: 'Anonymous'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(t.short, style: Ty.h2),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_outlined, size: 16, color: C.accent),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(t.title, style: Ty.small),
                  const SizedBox(height: 14),
                  Text('"${t.intro}"', style: Ty.bodyStrong.copyWith(fontSize: 14.5, color: C.text2, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const Divider(),
            _kv('Specializes in', t.focus.join(' · ')),
            const Divider(indent: 20, endIndent: 20),
            _kv('Experience', '${t.years} years'),
            const Divider(indent: 20, endIndent: 20),
            _kv('Response time', t.response),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Row(
                children: [
                  StatusDot(t.presence),
                  const SizedBox(width: 4),
                  Text(t.presence == Presence.online ? 'Available now' : t.presence.label, style: Ty.small.copyWith(color: C.text)),
                  const Spacer(),
                  if (shared.isNotEmpty) Text('MATCHED ON ${shared.join(' + ').toUpperCase()}', style: Ty.mono(size: 9, color: C.text4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            SizedBox(width: 120, child: Label(k)),
            Expanded(child: Text(v, textAlign: TextAlign.right, style: Ty.small.copyWith(color: C.text))),
          ],
        ),
      );
}

// ───────────────────────────── 9. Therapist profile ─────────────────────────────

class TherapistProfileScreen extends StatelessWidget {
  final Therapist therapist;
  final VoidCallback? onStart;
  final String ctaLabel;

  const TherapistProfileScreen({super.key, required this.therapist, this.onStart, this.ctaLabel = 'Start conversation'});

  @override
  Widget build(BuildContext context) {
    final t = therapist;
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              const TopBar(title: 'Profile'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  children: [
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Orbit(size: 150),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: C.bg, shape: BoxShape.circle),
                              child: Monogram(t.initials, size: 76, presence: t.presence),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t.name, style: Ty.h1.copyWith(fontSize: 24)),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified_outlined, size: 18, color: C.accent),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(t.title, textAlign: TextAlign.center, style: Ty.small),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Tag(t.presence == Presence.online ? 'Available' : t.presence.label, presence: t.presence),
                        const Tag('Verified', icon: Icons.verified_outlined),
                        Tag('${t.years} yrs'),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const SectionTitle('About'),
                    Text(t.bio, style: Ty.body),
                    const SizedBox(height: 28),
                    const SectionTitle('Approach'),
                    Text(t.approach, style: Ty.body),
                    const SizedBox(height: 28),
                    const SectionTitle('Specializes in'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: t.focus
                          .map((f) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: C.s1,
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(color: C.border),
                                ),
                                child: Text(f, style: Ty.small.copyWith(color: C.text)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                    const SectionTitle('Details'),
                    Group(children: [
                      RowTile(icon: Icons.work_outline_rounded, title: 'Experience', value: '${t.years} years', chevron: false),
                      RowTile(icon: Icons.translate_rounded, title: 'Languages', value: t.languages.join(', '), chevron: false),
                      RowTile(
                        icon: Icons.schedule_rounded,
                        title: 'Availability',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusDot(t.presence, size: 6),
                            Text(t.presence == Presence.online ? 'Online now' : t.lastActive, style: Ty.small.copyWith(color: C.text3)),
                          ],
                        ),
                      ),
                      RowTile(icon: Icons.bolt_outlined, title: 'Response time', value: t.response.replaceAll('Usually ', ''), chevron: false),
                    ]),
                    const SizedBox(height: 20),
                    Surface(
                      padding: const EdgeInsets.all(14),
                      color: C.accentA(0.05),
                      borderColor: C.accentA(0.2),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline_rounded, size: 16, color: C.accent),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text('Only your anonymous profile is visible to your therapist.', style: Ty.small.copyWith(color: C.text, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (onStart != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Btn(ctaLabel, onTap: onStart),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── 13. Therapist unavailable ─────────────────────────────

class TherapistUnavailableScreen extends StatelessWidget {
  const TherapistUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = app.assigned;
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              const TopBar(backIcon: Icons.close_rounded),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(width: 180, height: 180, child: ClipOval(child: DotGrid(spacing: 12, opacity: 0.14, focus: Alignment.center))),
                  Monogram(t.initials, size: 72, presence: Presence.offline),
                ],
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text('${t.short} is currently\nunavailable.', textAlign: TextAlign.center, style: Ty.h1),
                    const SizedBox(height: 12),
                    Text(
                      'Your messages are saved and will be delivered the moment she\'s back. You haven\'t done anything wrong by waiting.',
                      textAlign: TextAlign.center,
                      style: Ty.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Group(children: [
                  RowTile(icon: Icons.history_rounded, title: 'Last active', value: t.lastActive == 'Active now' ? '42 min ago' : t.lastActive, chevron: false),
                  const RowTile(icon: Icons.schedule_rounded, title: 'Expected response', value: 'Within 2–3 hours', chevron: false),
                ]),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  children: [
                    Btn('Continue waiting', onTap: () => Navigator.of(context).pop()),
                    const SizedBox(height: 8),
                    Btn.ghost('Find another therapist', onTap: () => Navigator.of(context).pushReplacement(fade(const FindingScreen(reassign: true)))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
