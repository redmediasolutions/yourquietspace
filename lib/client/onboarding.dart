import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../admin/admin.dart';
import '../core/design_system.dart';
import '../core/state.dart';
import '../core/theme.dart';
import '../core/visuals.dart';
import '../core/widgets.dart';
import '../therapist/therapist_app.dart';
import 'matching.dart';

// ───────────────────────────── 1. Splash ─────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1900))..forward();

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(fade(const WelcomeScreen()));
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fadeIn = CurvedAnimation(parent: _c, curve: const Interval(0, 0.4, curve: Curves.easeOut));
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: DotGrid(focus: Alignment.center, opacity: 0.06)),
          Center(
            child: FadeTransition(
              opacity: fadeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandMark(size: 44),
                  const SizedBox(height: 18),
                  Text('Therapist', style: Ty.title.copyWith(letterSpacing: -0.3)),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: Column(
              children: [
                SizedBox(
                  width: 56,
                  height: 1.5,
                  child: AnimatedBuilder(
                    animation: _c,
                    builder: (_, __) => Stack(
                      children: [
                        Container(color: C.border),
                        FractionallySizedBox(widthFactor: _c.value, child: Container(color: C.text2)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Label('Private · Anonymous', color: C.text4, size: 9.5),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── 2. Welcome ─────────────────────────────

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: DotGrid(opacity: 0.07)),
          const Positioned(top: -120, left: 0, right: 0, child: Center(child: Glow(size: 460, opacity: 0.08))),
          SafeArea(
            child: Narrow(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Wordmark(size: 14),
                        Spacer(),
                        Tag('Anonymous', icon: Icons.visibility_off_outlined),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: Orbit(
                          size: math.min(300, h * 0.36),
                          center: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: C.text,
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: C.text.withValues(alpha: 0.4), blurRadius: 18)],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Label('A private place to talk'),
                    const SizedBox(height: 14),
                    Text('You don\'t have to\ncarry it alone.', style: Ty.display),
                    const SizedBox(height: 14),
                    Text(
                      'Talk one-to-one with a licensed therapist — under a nickname, without sharing who you are.',
                      style: Ty.body,
                    ),
                    const SizedBox(height: 28),
                    Btn('Get started', onTap: () => Navigator.of(context).push(fade(const PrivacyIntroScreen()))),
                    const SizedBox(height: 8),
                    Btn.ghost(
                      'How privacy works',
                      icon: Icons.lock_outline_rounded,
                      onTap: () => Navigator.of(context).push(fade(const PrivacyIntroScreen())),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _foot('Therapist login', () => Navigator.of(context).push(fade(const TherapistLoginScreen()))),
                        _sep(),
                        _foot('Admin', () => Navigator.of(context).push(fade(const AdminShell()))),
                        _sep(),
                        _foot('Components', () => Navigator.of(context).push(fade(const DesignSystemScreen()))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _foot(String s, VoidCallback onTap) => Pressable(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Text(s.toUpperCase(), style: Ty.mono(size: 9.5, color: C.text3)),
        ),
      );

  Widget _sep() => Text('·', style: Ty.mono(color: C.text4));
}

// ───────────────────────────── 3. Privacy intro ─────────────────────────────

class PrivacyIntroScreen extends StatelessWidget {
  const PrivacyIntroScreen({super.key});

  static const points = [
    ('Use a nickname', 'No real name, phone number or photo required. Ever.'),
    ('Your identity stays yours', 'Your therapist sees your nickname — not who you are.'),
    ('Conversations are private', 'Messages are encrypted in transit and at rest.'),
    ('Only two people', 'Just you and your assigned therapist can read the conversation.'),
    ('No casual access', 'Admins manage accounts and safety reports — they don\'t browse chats.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              const TopBar(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    const Center(child: LockMark(size: 168)),
                    const SizedBox(height: 28),
                    const Label('How privacy works'),
                    const SizedBox(height: 10),
                    Text('Private by design,\nnot by setting.', style: Ty.h1),
                    const SizedBox(height: 10),
                    Text('Here\'s exactly what happens to what you share.', style: Ty.body),
                    const SizedBox(height: 26),
                    for (var i = 0; i < points.length; i++) _PrivacyPoint(index: i + 1, title: points[i].$1, body: points[i].$2),
                    const SizedBox(height: 10),
                    Surface(
                      padding: const EdgeInsets.all(14),
                      color: C.bg,
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: C.text3),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'If you share that you or someone else is in immediate danger, your therapist may share emergency resources with you.',
                              style: Ty.tiny.copyWith(height: 1.5, fontSize: 12),
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
                child: Btn(
                  'Continue privately',
                  icon: Icons.arrow_forward_rounded,
                  onTap: () => Navigator.of(context).push(fade(const ProfileCreateScreen())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  final int index;
  final String title;
  final String body;

  const _PrivacyPoint({required this.index, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 8 * (1 - v)), child: child)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.hairline))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 34, child: Text(index.toString().padLeft(2, '0'), style: Ty.mono(color: C.accent, size: 11))),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Ty.title.copyWith(fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(body, style: Ty.small),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── 4. Anonymous profile ─────────────────────────────

class ProfileCreateScreen extends StatefulWidget {
  const ProfileCreateScreen({super.key});

  @override
  State<ProfileCreateScreen> createState() => _ProfileCreateScreenState();
}

class _ProfileCreateScreenState extends State<ProfileCreateScreen> {
  final _name = TextEditingController(text: app.nickname);
  String? _age = app.ageRange;
  final _rand = math.Random();

  static const _ages = ['18–24', '25–34', '35–44', '45–54', '55+', 'Prefer not to say'];
  static const _a = ['Quiet', 'Still', 'Soft', 'Calm', 'Grey', 'Paper', 'Night', 'Slow', 'Low', 'Blue'];
  static const _b = ['Mind', 'Water', 'Owl', 'Boat', 'Fog', 'River', 'Lane', 'Harbor', 'Field', 'Tide'];

  String? get _error {
    final v = _name.text.trim();
    if (v.isEmpty) return 'Choose a nickname to continue';
    if (v.length < 3) return 'At least 3 characters';
    if (v.contains(' ')) return 'No spaces — try QuietMind55';
    return null;
  }

  void _shuffle() {
    setState(() => _name.text = '${_a[_rand.nextInt(_a.length)]}${_b[_rand.nextInt(_b.length)]}${10 + _rand.nextInt(89)}');
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final err = _error;
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              const TopBar(),
              const Padding(padding: EdgeInsets.fromLTRB(24, 4, 24, 0), child: StepBar(step: 1, total: 3)),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  children: [
                    Text('Choose how you\'ll\nappear.', style: Ty.h1),
                    const SizedBox(height: 10),
                    Text('Pick a nickname. It\'s the only name your therapist will ever see.', style: Ty.body),
                    const SizedBox(height: 28),
                    Field(
                      label: 'Anonymous nickname',
                      controller: _name,
                      mono: true,
                      maxLength: 20,
                      onChanged: (_) => setState(() {}),
                      error: _name.text.isEmpty ? null : err,
                      helper: 'Letters and numbers. You can change it later.',
                      suffix: IconButton(
                        tooltip: 'Suggest another',
                        onPressed: _shuffle,
                        icon: const Icon(Icons.shuffle_rounded, size: 18, color: C.text2),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Label('Age range'),
                        const SizedBox(width: 8),
                        Text('· optional', style: Ty.tiny),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _ages
                          .map((a) => ChoiceChipX(label: a, selected: _age == a, onTap: () => setState(() => _age = _age == a ? null : a)))
                          .toList(),
                    ),
                    const SizedBox(height: 28),
                    // Who sees what — privacy made visible
                    Surface(
                      padding: const EdgeInsets.all(16),
                      color: C.bg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.visibility_outlined, size: 15, color: C.accent),
                              SizedBox(width: 8),
                              Label('What your therapist sees', color: C.accent),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Monogram(_name.text.isEmpty ? '?' : _name.text, size: 38, accent: true),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_name.text.isEmpty ? '—' : _name.text, style: Ty.mono(size: 14, color: C.text, ls: 0.3)),
                                    const SizedBox(height: 3),
                                    Text(_age == null ? 'Age not shared' : 'Age $_age', style: Ty.tiny),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(),
                          const SizedBox(height: 12),
                          Text('Not shared: real name, email, phone, location, contacts.', style: Ty.tiny.copyWith(height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Btn(
                  'Continue',
                  onTap: err != null
                      ? null
                      : () {
                          app.nickname = _name.text.trim();
                          app.ageRange = _age;
                          Navigator.of(context).push(fade(const ConcernsScreen()));
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── 5. Concerns ─────────────────────────────

class ConcernsScreen extends StatefulWidget {
  const ConcernsScreen({super.key});

  @override
  State<ConcernsScreen> createState() => _ConcernsScreenState();
}

class _ConcernsScreenState extends State<ConcernsScreen> {
  static const options = ['Stress', 'Anxiety', 'Sleep', 'Relationships', 'Work', 'Loneliness', 'Family', 'Confidence', 'Something else'];

  @override
  Widget build(BuildContext context) {
    final sel = app.concerns;
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              const TopBar(),
              const Padding(padding: EdgeInsets.fromLTRB(24, 4, 24, 0), child: StepBar(step: 2, total: 3)),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  children: [
                    Text('What would you like\nsupport with?', style: Ty.h1),
                    const SizedBox(height: 10),
                    Text('Choose as many as feel right. This only helps us find a good match — it isn\'t a diagnosis.', style: Ty.body),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: options
                          .map((o) => ChoiceChipX(
                                label: o,
                                selected: sel.contains(o),
                                onTap: () => setState(() => sel.contains(o) ? sel.remove(o) : sel.add(o)),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        sel.isEmpty ? 'Nothing selected yet' : '${sel.length} selected',
                        key: ValueKey(sel.length),
                        style: Ty.mono(color: sel.isEmpty ? C.text4 : C.text3),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Btn('Continue', onTap: sel.isEmpty ? null : () => Navigator.of(context).push(fade(const TellMoreScreen()))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── 6. Tell us more ─────────────────────────────

class TellMoreScreen extends StatefulWidget {
  const TellMoreScreen({super.key});

  @override
  State<TellMoreScreen> createState() => _TellMoreScreenState();
}

class _TellMoreScreenState extends State<TellMoreScreen> {
  final _c = TextEditingController(text: app.story);
  static const max = 1000;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _go() {
    app.story = _c.text.trim();
    Navigator.of(context).push(fade(const FindingScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final n = _c.text.characters.length;
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              TopBar(actions: [TextLink('Skip', color: C.text3, onTap: _go)]),
              const Padding(padding: EdgeInsets.fromLTRB(24, 4, 24, 0), child: StepBar(step: 3, total: 3)),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  children: [
                    Text('Share whatever\nfeels comfortable.', style: Ty.h1),
                    const SizedBox(height: 10),
                    Text('A few words or a few paragraphs. Your therapist will read this before saying hello.', style: Ty.body),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: C.s1,
                        borderRadius: BorderRadius.circular(R.md),
                        border: Border.all(color: C.border),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _c,
                            maxLines: 9,
                            minLines: 9,
                            maxLength: max,
                            onChanged: (_) => setState(() {}),
                            style: Ty.bodyStrong.copyWith(height: 1.6),
                            decoration: const InputDecoration(
                              hintText: 'Lately I\'ve been…',
                              counterText: '',
                              filled: false,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.all(18),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(18, 10, 14, 10),
                            decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.hairline))),
                            child: Row(
                              children: [
                                Expanded(child: Text(app.concerns.join(' · '), style: Ty.tiny, overflow: TextOverflow.ellipsis)),
                                const SizedBox(width: 12),
                                Text('$n / $max', style: Ty.mono(color: n > max * 0.9 ? C.away : C.text4, ls: 0.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(Icons.lock_outline_rounded, size: 14, color: C.accent),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Only your matched therapist can read this. It\'s stored encrypted and never shown with your real identity.',
                            style: Ty.tiny.copyWith(height: 1.5, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Btn('Find my therapist', onTap: _go),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
