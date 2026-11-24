import 'package:flutter/material.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../core/visuals.dart';
import '../core/widgets.dart';

/// Private-note palette: a warm, paper-dark surface with an amber edge.
/// Deliberately unlike any client-visible message.
class _NoteColors {
  static const bg = Color(0xFF16140E);
  static const edge = Color(0xFF3A3220);
  static const ink = C.away;
}

// ───────────────────────────── 24. Login ─────────────────────────────

class TherapistLoginScreen extends StatefulWidget {
  const TherapistLoginScreen({super.key});

  @override
  State<TherapistLoginScreen> createState() => _TherapistLoginScreenState();
}

class _TherapistLoginScreenState extends State<TherapistLoginScreen> {
  final _email = TextEditingController(text: 'maya.raman@therapist.app');
  final _pass = TextEditingController(text: 'calm-harbor-42');
  bool _loading = false;
  bool _otp = false;
  String? _error;
  String _code = '';

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_pass.text.length < 6) {
      setState(() => _error = 'That password doesn\'t look right. Try again or reset it.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() {
      _loading = false;
      _otp = true;
    });
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(fade(const TherapistShell()), (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: DotGrid(opacity: 0.05)),
          SafeArea(
            child: Narrow(
              max: 440,
              child: Column(
                children: [
                  TopBar(
                    onBack: _otp ? () => setState(() => _otp = false) : null,
                    titleWidget: const Label('Therapist portal'),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: _otp ? _otpStep() : _loginStep(),
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

  Widget _loginStep() {
    return ListView(
      key: const ValueKey('login'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        const BrandMark(size: 40),
        const SizedBox(height: 24),
        Text('Welcome back.', style: Ty.h1),
        const SizedBox(height: 8),
        Text('Sign in to see your conversations.', style: Ty.body),
        const SizedBox(height: 32),
        Field(label: 'Email or username', controller: _email, prefix: Icons.alternate_email_rounded, keyboard: TextInputType.emailAddress),
        const SizedBox(height: 18),
        Field(label: 'Password', controller: _pass, password: true, prefix: Icons.key_outlined, error: _error, onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        }),
        Align(
          alignment: Alignment.centerRight,
          child: TextLink('Forgot password?', size: 13, onTap: _forgot),
        ),
        const SizedBox(height: 16),
        Btn('Sign in', loading: _loading, onTap: _signIn),
        const SizedBox(height: 28),
        Surface(
          padding: const EdgeInsets.all(14),
          color: C.bg,
          child: Column(
            children: [
              _secure(Icons.verified_user_outlined, 'Two-step verification required'),
              const SizedBox(height: 10),
              _secure(Icons.timer_outlined, 'Signs out after 30 minutes of inactivity'),
              const SizedBox(height: 10),
              _secure(Icons.devices_outlined, 'New devices must be approved by an admin'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _secure(IconData i, String s) => Row(
        children: [
          Icon(i, size: 15, color: C.text3),
          const SizedBox(width: 10),
          Expanded(child: Text(s, style: Ty.tiny.copyWith(fontSize: 12.5))),
        ],
      );

  Widget _otpStep() {
    return ListView(
      key: const ValueKey('otp'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        Text('Enter your code.', style: Ty.h1),
        const SizedBox(height: 8),
        Text('We sent a 6-digit code to your authenticator app.', style: Ty.body),
        const SizedBox(height: 32),
        _OtpBoxes(value: _code, onChanged: (v) => setState(() => _code = v)),
        const SizedBox(height: 14),
        Text('Use 123456 for this demo.', style: Ty.tiny),
        const SizedBox(height: 28),
        Btn('Verify', loading: _loading, onTap: _code.length == 6 ? _verify : null),
        const SizedBox(height: 8),
        Btn.ghost('Use a backup code', onTap: () => showToast(context, 'Backup codes are in your admin email', icon: Icons.key_outlined)),
      ],
    );
  }

  void _forgot() {
    showSheet(
      context,
      label: 'Account',
      title: 'Reset password',
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('We\'ll email a reset link to your registered work address. For security, links expire after 15 minutes.', style: Ty.small),
          const SizedBox(height: 16),
          const Field(hint: 'Work email', prefix: Icons.alternate_email_rounded),
          const SizedBox(height: 16),
          Btn('Send reset link', onTap: () {
            Navigator.pop(ctx);
            showToast(context, 'If that email is registered, a link is on its way', icon: Icons.mail_outline_rounded);
          }),
        ],
      ),
    );
  }
}

class _OtpBoxes extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _OtpBoxes({required this.value, required this.onChanged});

  @override
  State<_OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<_OtpBoxes> {
  final _c = TextEditingController();
  final _f = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _f.requestFocus());
  }

  @override
  void dispose() {
    _c.dispose();
    _f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.value;
    return GestureDetector(
      onTap: () => _f.requestFocus(),
      child: Stack(
        children: [
          Opacity(
            opacity: 0,
            child: TextField(
              controller: _c,
              focusNode: _f,
              maxLength: 6,
              keyboardType: TextInputType.number,
              onChanged: (s) => widget.onChanged(s.replaceAll(RegExp(r'[^0-9]'), '')),
            ),
          ),
          Row(
            children: List.generate(6, (i) {
              final filled = i < v.length;
              final active = i == v.length;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: EdgeInsets.only(right: i == 5 ? 0 : 8, left: i == 3 ? 6 : 0),
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: C.s1,
                    borderRadius: BorderRadius.circular(R.sm),
                    border: Border.all(color: active ? C.accentA(0.7) : (filled ? C.text3 : C.border)),
                  ),
                  child: Text(filled ? v[i] : '', style: Ty.mono(size: 20, color: C.text, ls: 0)),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Shell ─────────────────────────────

class TherapistShell extends StatefulWidget {
  const TherapistShell({super.key});

  @override
  State<TherapistShell> createState() => _TherapistShellState();
}

class _TherapistShellState extends State<TherapistShell> {
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      TherapistDashboard(onOpenList: () => setState(() => _i = 1)),
      const TherapistConversations(),
      const TherapistAccount(),
    ];
    const items = [
      (Icons.today_outlined, 'Today'),
      (Icons.forum_outlined, 'Conversations'),
      (Icons.person_outline_rounded, 'Account'),
    ];
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final unread = app.clients.fold<int>(0, (a, c) => a + c.unread);
        return Scaffold(
          body: IndexedStack(index: _i, children: pages),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(color: C.bg, border: Border(top: BorderSide(color: C.hairline))),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 60,
                child: Row(
                  children: List.generate(items.length, (i) {
                    final (icon, label) = items[i];
                    final active = i == _i;
                    return Expanded(
                      child: Pressable(
                        onTap: () => setState(() => _i = i),
                        scale: 0.94,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(icon, size: 21, color: active ? C.accent : C.text3),
                                if (i == 1 && unread > 0)
                                  Positioned(
                                    right: -10,
                                    top: -5,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(99)),
                                      child: Text('$unread', style: Ty.mono(size: 9, color: C.bg, ls: 0)),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(label, style: Ty.tiny.copyWith(fontSize: 10.5, color: active ? C.text : C.text3, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ───────────────────────────── 25. Dashboard ─────────────────────────────

class TherapistDashboard extends StatelessWidget {
  final VoidCallback onOpenList;

  const TherapistDashboard({super.key, required this.onOpenList});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final active = app.clients.where((c) => c.status != ClientStatus.closed).length;
        final waiting = app.clients.where((c) => c.status == ClientStatus.waiting).toList();
        final unread = app.clients.fold<int>(0, (a, c) => a + c.unread);
        final g = greeting().replaceAll('.', '');
        return SafeArea(
          child: Narrow(
            max: 760,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Row(
                  children: [
                    Expanded(child: Label(fmtDate(DateTime.now()))),
                    IconBtn(Icons.notifications_none_rounded, dot: true, onTap: () => _notifications(context)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('$g, Maya.', style: Ty.h1),
                const SizedBox(height: 22),

                // Availability
                Surface(
                  onTap: () => Navigator.of(context).push(fade(const AvailabilityScreen())),
                  child: Row(
                    children: [
                      StatusDot(app.myPresence, size: 9),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Label('Availability', size: 9),
                          const SizedBox(height: 4),
                          Text(app.myPresence.label.toUpperCase(), style: Ty.mono(size: 15, color: app.myPresence.color, ls: 1.4, w: FontWeight.w600)),
                        ],
                      ),
                      const Spacer(),
                      Text(_responseFor(app.myPresence), style: Ty.tiny),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: C.text4),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Counts — three quiet numbers, no charts
                Row(
                  children: [
                    _Count(label: 'Assigned', value: active, onTap: onOpenList),
                    const SizedBox(width: 10),
                    _Count(label: 'Waiting', value: waiting.length, highlight: waiting.isNotEmpty, onTap: onOpenList),
                    const SizedBox(width: 10),
                    _Count(label: 'Unread', value: unread, onTap: onOpenList),
                  ],
                ),
                const SizedBox(height: 28),

                SectionTitle('Waiting for you', action: 'All', onAction: onOpenList),
                if (waiting.isEmpty)
                  Surface(child: Text('No one is waiting. Nice work.', style: Ty.small))
                else
                  Group(children: waiting.map((c) => _ClientRow(client: c)).toList()),
                const SizedBox(height: 28),

                const SectionTitle('Recent activity'),
                const Surface(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Column(
                    children: [
                      _Activity('18:41', 'QuietMind55 sent 2 messages'),
                      _Activity('18:25', 'You added a private note · QuietMind55'),
                      _Activity('18:02', 'NightOwl_08 was assigned to you'),
                      _Activity('16:40', 'You closed the session with Ember_Lane'),
                      _Activity('09:12', 'You went online', last: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _notifications(BuildContext context) {
    showSheet(
      context,
      label: 'Notifications',
      title: 'Recent',
      builder: (_) => const Group(children: [
        RowTile(icon: Icons.person_add_alt_outlined, title: 'New client assigned', subtitle: 'NightOwl_08 · Anxiety, Loneliness · 9m', chevron: false),
        RowTile(icon: Icons.chat_bubble_outline_rounded, title: '2 new messages', subtitle: 'QuietMind55 · 2m', chevron: false),
        RowTile(icon: Icons.swap_horiz_rounded, title: 'Reassignment approved', subtitle: 'PaperBoat3 stays with you · Mon', chevron: false),
      ]),
    );
  }
}

String _responseFor(Presence p) => switch (p) {
      Presence.online => 'Replies in minutes',
      Presence.away => 'Replies within an hour',
      Presence.offline => 'Back tomorrow 10:00',
    };

class _Count extends StatelessWidget {
  final String label;
  final int value;
  final bool highlight;
  final VoidCallback onTap;

  const _Count({required this.label, required this.value, this.highlight = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Surface(
        onTap: onTap,
        padding: const EdgeInsets.all(16),
        borderColor: highlight ? C.accentA(0.3) : C.border,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label(label, size: 9, color: highlight ? C.accent : C.text3),
            const SizedBox(height: 12),
            Text('$value', style: Ty.mono(size: 26, color: C.text, ls: -0.5, w: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}

class _Activity extends StatelessWidget {
  final String time;
  final String text;
  final bool last;

  const _Activity(this.time, this.text, {this.last = false});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(width: 46, child: Padding(padding: const EdgeInsets.only(top: 12), child: Text(time, style: Ty.mono(size: 10, color: C.text4, ls: 0.3)))),
          Column(
            children: [
              const SizedBox(height: 15),
              Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.text3))),
              if (!last) Expanded(child: Container(width: 1, color: C.hairline)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(text, style: Ty.small.copyWith(fontSize: 13.5)))),
        ],
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  final ClientConv client;
  final VoidCallback? onTap;
  final bool selected;

  const _ClientRow({required this.client, this.onTap, this.selected = false});

  @override
  Widget build(BuildContext context) {
    final c = client;
    final (statusLabel, statusColor) = switch (c.status) {
      ClientStatus.waiting => ('Waiting', C.accent),
      ClientStatus.active => ('Active', C.text3),
      ClientStatus.closed => ('Closed', C.text4),
    };
    return Pressable(
      onTap: onTap ?? () => Navigator.of(context).push(fade(TherapistChatScreen(nickname: c.nickname))),
      scale: 0.995,
      child: Container(
        color: selected ? C.s2 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Monogram(c.nickname, size: 40, accent: c.unread > 0),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(c.nickname, overflow: TextOverflow.ellipsis, style: Ty.mono(size: 13.5, color: C.text, ls: 0.2))),
                      const SizedBox(width: 8),
                      if (c.priority) const Tag('Priority', color: C.warm, filled: true),
                      const Spacer(),
                      Text(c.time, style: Ty.mono(size: 9.5, color: c.unread > 0 ? C.accent : C.text4, ls: 0.3)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Ty.small.copyWith(fontSize: 13.5, color: c.unread > 0 ? C.text : C.text3),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(statusLabel.toUpperCase(), style: Ty.mono(size: 9, color: statusColor)),
                      Expanded(
                        child: Text('  ·  ${c.concerns.join(', ')}', overflow: TextOverflow.ellipsis, style: Ty.tiny.copyWith(fontSize: 11)),
                      ),
                      if (c.unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(99)),
                          child: Text('${c.unread} unread', style: Ty.mono(size: 9, color: C.bg, ls: 0.2)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── 29. Availability ─────────────────────────────

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  late Presence _p = app.myPresence;
  bool _accepting = true;

  static const _desc = {
    Presence.online: 'Clients see you\'re available. New matches can be assigned to you.',
    Presence.away: 'Clients see you\'re away. Messages queue; no new matches.',
    Presence.offline: 'You won\'t receive notifications. Clients see when you\'ll be back.',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              const TopBar(title: 'Availability'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: _p == Presence.offline ? 0.3 : 1,
                              child: const Orbit(size: 200),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: C.bg,
                                border: Border.all(color: _p.color.withValues(alpha: 0.6)),
                                boxShadow: [BoxShadow(color: _p.color.withValues(alpha: _p == Presence.offline ? 0 : 0.25), blurRadius: 40)],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    StatusDot(_p, size: 8),
                                    Text(_p.label.toUpperCase(), style: Ty.mono(size: 11, color: _p.color, ls: 1.4)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final p in Presence.values) ...[
                      _PresenceOption(presence: p, selected: _p == p, desc: _desc[p]!, onTap: () => setState(() => _p = p)),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 16),
                    const SectionTitle('Shown to clients'),
                    Surface(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded, size: 18, color: C.text2),
                          const SizedBox(width: 12),
                          Expanded(child: Text('Expected response', style: Ty.small.copyWith(color: C.text))),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(_responseFor(_p), key: ValueKey(_p), style: Ty.mono(size: 11.5, color: C.text2, ls: 0.3)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Group(children: [
                      RowTile(
                        title: 'Accept new clients',
                        subtitle: _accepting ? 'You can be matched with new people' : 'Only existing clients can reach you',
                        trailing: Switch(value: _accepting, onChanged: (v) => setState(() => _accepting = v)),
                      ),
                      const RowTile(title: 'Working hours', value: 'Mon–Fri · 10:00–19:00', chevron: false),
                      const RowTile(title: 'Auto-away after', value: '15 min idle', chevron: false),
                    ]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Btn('Update status', onTap: () {
                  app.setMyPresence(_p);
                  showToast(context, 'You\'re now ${_p.label.toLowerCase()}', icon: Icons.circle);
                  Navigator.of(context).pop();
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresenceOption extends StatelessWidget {
  final Presence presence;
  final bool selected;
  final String desc;
  final VoidCallback onTap;

  const _PresenceOption({required this.presence, required this.selected, required this.desc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? C.s2 : C.s1,
          borderRadius: BorderRadius.circular(R.md),
          border: Border.all(color: selected ? presence.color.withValues(alpha: 0.5) : C.border),
        ),
        child: Row(
          children: [
            StatusDot(presence, size: 8),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(presence.label, style: Ty.title.copyWith(fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(desc, style: Ty.tiny.copyWith(fontSize: 12.5, height: 1.45)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? C.accent : C.border, width: selected ? 5 : 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── 26. Conversation list ─────────────────────────────

class TherapistConversations extends StatefulWidget {
  const TherapistConversations({super.key});

  @override
  State<TherapistConversations> createState() => _TherapistConversationsState();
}

class _TherapistConversationsState extends State<TherapistConversations> {
  int _filter = 0;
  String _q = '';
  String? _selected; // wide layout only

  static const filters = ['All', 'Waiting', 'Active', 'Closed'];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final list = app.clients.where((c) {
          final f = switch (_filter) {
            1 => c.status == ClientStatus.waiting,
            2 => c.status == ClientStatus.active,
            3 => c.status == ClientStatus.closed,
            _ => true,
          };
          return f && c.nickname.toLowerCase().contains(_q.toLowerCase());
        }).toList()
          ..sort((a, b) => (b.priority ? 1 : 0).compareTo(a.priority ? 1 : 0));

        return LayoutBuilder(builder: (context, box) {
          final wide = box.maxWidth >= 900;
          final listPane = SafeArea(
            right: !wide,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Conversations', style: Ty.h1),
                      const SizedBox(height: 16),
                      Field(hint: 'Search nickname', prefix: Icons.search_rounded, onChanged: (v) => setState(() => _q = v)),
                      const SizedBox(height: 12),
                      Segmented(items: filters, index: _filter, onChanged: (i) => setState(() => _filter = i), height: 38),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                Expanded(
                  child: list.isEmpty
                      ? const EmptyState(icon: Icons.forum_outlined, title: 'Nothing here', body: 'No conversations match this filter.')
                      : ListView.separated(
                          padding: const EdgeInsets.only(bottom: 24),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(indent: 68),
                          itemBuilder: (_, i) => _ClientRow(
                            client: list[i],
                            selected: wide && _selected == list[i].nickname,
                            onTap: wide
                                ? () => setState(() => _selected = list[i].nickname)
                                : null,
                          ),
                        ),
                ),
              ],
            ),
          );

          if (!wide) return listPane;
          return Row(
            children: [
              SizedBox(width: 380, child: listPane),
              const VerticalDivider(width: 1, color: C.hairline),
              Expanded(
                child: _selected == null
                    ? const Center(
                        child: EmptyState(icon: Icons.forum_outlined, title: 'Select a conversation', body: 'Messages and private notes appear here.'),
                      )
                    : TherapistChatScreen(key: ValueKey(_selected), nickname: _selected!, embedded: true),
              ),
            ],
          );
        });
      },
    );
  }
}

// ───────────────────────────── 27. Therapist chat ─────────────────────────────

class TherapistChatScreen extends StatefulWidget {
  final String nickname;
  final bool embedded;

  const TherapistChatScreen({super.key, required this.nickname, this.embedded = false});

  @override
  State<TherapistChatScreen> createState() => _TherapistChatScreenState();
}

class _TherapistChatScreenState extends State<TherapistChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _notesOpen = false;

  ClientConv get _client => app.clients.firstWhere((c) => c.nickname == widget.nickname);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _client.unread = 0;
      if (_client.status == ClientStatus.waiting) _client.status = ClientStatus.active;
      app.update();
      _toEnd(jump: true);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toEnd({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final m = _scroll.position.maxScrollExtent;
      if (jump) {
        _scroll.jumpTo(m);
      } else {
        _scroll.animateTo(m, duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
      }
    });
  }

  void _send() {
    final t = _input.text.trim();
    if (t.isEmpty) return;
    app.therapistSend(t, widget.nickname);
    if (widget.nickname == AppState.demoClient) {
      // Mirror into the client demo so both sides stay consistent.
      app.messages.add(Msg(id: 'mirror${DateTime.now().microsecondsSinceEpoch}', text: t, mine: false, at: DateTime.now()));
      app.unreadFromTherapist++;
      if (app.conv == ConvState.empty) app.conv = ConvState.active;
      app.update();
    }
    _input.clear();
    setState(() {});
    _toEnd();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final sidePanel = box.maxWidth >= 860;
      final chat = ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final c = _client;
          final msgs = app.threadFor(c.nickname);
          final closed = c.status == ClientStatus.closed;
          final noteCount = app.notes.where((n) => n.client == c.nickname).length;
          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    if (!widget.embedded) ...[IconBtn(Icons.chevron_left_rounded, onTap: () => Navigator.of(context).maybePop()), const SizedBox(width: 10)],
                    Monogram(c.nickname, size: 38, accent: true),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.nickname, style: Ty.mono(size: 14, color: C.text, ls: 0.2)),
                          const SizedBox(height: 2),
                          Text(closed ? 'Session closed' : 'Anonymous client · ${c.concerns.join(', ')}', overflow: TextOverflow.ellipsis, style: Ty.tiny),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: 'Private notes',
                      child: Pressable(
                        onTap: () => sidePanel ? setState(() => _notesOpen = !_notesOpen) : _openNotesSheet(context),
                        scale: 0.94,
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _notesOpen && sidePanel ? _NoteColors.bg : C.s1,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _notesOpen && sidePanel ? _NoteColors.edge : C.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sticky_note_2_outlined, size: 17, color: _NoteColors.ink),
                              const SizedBox(width: 6),
                              Text('$noteCount', style: Ty.mono(size: 11, color: _NoteColors.ink, ls: 0)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconBtn(Icons.more_horiz_rounded, onTap: () => _menu(context, c)),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [
                    _IntakeCard(client: c),
                    for (var i = 0; i < msgs.length; i++)
                      _TBubble(
                        msg: msgs[i],
                        tight: i > 0 && msgs[i - 1].mine == msgs[i].mine && msgs[i].at.difference(msgs[i - 1].at).inMinutes < 4,
                        showStatus: msgs[i].mine && !msgs.skip(i + 1).any((x) => x.mine),
                      ),
                    if (closed)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Center(child: Label('Session closed · ${fmtTime(DateTime.now())}', color: C.text4)),
                      ),
                  ],
                ),
              ),
              if (closed)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.hairline))),
                  child: Text('This session is closed. The client can request support again.', textAlign: TextAlign.center, style: Ty.small),
                )
              else
                _composer(),
            ],
          );
        },
      );

      if (!sidePanel) return widget.embedded ? chat : Scaffold(body: SafeArea(child: chat));
      final row = Row(
        children: [
          Expanded(child: chat),
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: _notesOpen ? 340 : 0,
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.centerLeft,
                minWidth: 340,
                maxWidth: 340,
                child: Container(
                  decoration: const BoxDecoration(color: _NoteColors.bg, border: Border(left: BorderSide(color: _NoteColors.edge))),
                  child: NotesPanel(client: widget.nickname, onClose: () => setState(() => _notesOpen = false)),
                ),
              ),
            ),
          ),
        ],
      );
      return widget.embedded ? row : Scaffold(body: SafeArea(child: row));
    });
  }

  Widget _composer() {
    final can = _input.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.hairline))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 5,
                  onChanged: (_) => setState(() {}),
                  style: Ty.bodyStrong.copyWith(fontSize: 15, height: 1.4),
                  decoration: InputDecoration(
                    hintText: 'Reply to ${widget.nickname}…',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(21), borderSide: const BorderSide(color: C.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(21), borderSide: const BorderSide(color: C.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(21), borderSide: BorderSide(color: C.accentA(0.6))),
                    contentPadding: const EdgeInsets.fromLTRB(16, 11, 16, 11),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Pressable(
                onTap: can ? _send : null,
                scale: 0.9,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: can ? C.text : C.s2, shape: BoxShape.circle, border: Border.all(color: can ? C.text : C.border)),
                  child: Icon(Icons.arrow_upward_rounded, size: 20, color: can ? C.bg : C.text4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.visibility_outlined, size: 10, color: C.text4),
              const SizedBox(width: 5),
              Text('VISIBLE TO CLIENT · USE NOTES FOR PRIVATE THOUGHTS', style: Ty.mono(size: 8.5, color: C.text4)),
            ],
          ),
        ],
      ),
    );
  }

  void _openNotesSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: Container(
          height: MediaQuery.sizeOf(ctx).height * 0.82,
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          decoration: BoxDecoration(
            color: _NoteColors.bg,
            borderRadius: BorderRadius.circular(R.lg + 4),
            border: Border.all(color: _NoteColors.edge),
          ),
          child: NotesPanel(client: widget.nickname, onClose: () => Navigator.pop(ctx)),
        ),
      ),
    );
  }

  void _menu(BuildContext context, ClientConv c) {
    showSheet(
      context,
      label: c.nickname,
      builder: (ctx) => Group(children: [
        RowTile(
          icon: Icons.info_outline_rounded,
          title: 'Client details',
          subtitle: '${c.ageRange} · with you ${c.since}',
          chevron: false,
        ),
        RowTile(
          icon: Icons.swap_horiz_rounded,
          title: 'Request reassignment',
          onTap: () {
            Navigator.pop(ctx);
            Navigator.of(context).push(fade(ReassignScreen(nickname: c.nickname)));
          },
        ),
        RowTile(
          icon: Icons.logout_rounded,
          title: 'Close session',
          titleColor: C.warm,
          onTap: () {
            Navigator.pop(ctx);
            Navigator.of(context).push(fade(CloseSessionScreen(nickname: c.nickname)));
          },
        ),
      ]),
    );
  }
}

class _IntakeCard extends StatelessWidget {
  final ClientConv client;

  const _IntakeCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final story = client.nickname == AppState.demoClient && app.story.isNotEmpty
        ? app.story
        : 'Work has been really intense and I can\'t switch off at night. I\'d like to feel less on edge.';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(R.sm), border: Border.all(color: C.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Label('Shared at intake', size: 9),
                const Spacer(),
                Text(client.ageRange, style: Ty.mono(size: 9.5, color: C.text4, ls: 0.3)),
              ],
            ),
            const SizedBox(height: 8),
            Text(story, style: Ty.small.copyWith(fontSize: 13.5, color: C.text2)),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: client.concerns.map((x) => Tag(x)).toList()),
          ],
        ),
      ),
    );
  }
}

class _TBubble extends StatelessWidget {
  final Msg msg;
  final bool tight;
  final bool showStatus;

  const _TBubble({required this.msg, required this.tight, required this.showStatus});

  @override
  Widget build(BuildContext context) {
    final mine = msg.mine;
    final maxW = (MediaQuery.sizeOf(context).width.clamp(0, 640) * 0.74).toDouble();
    final (IconData sIcon, String sLabel, Color sColor) = switch (msg.status) {
      MsgStatus.sending => (Icons.schedule_rounded, 'Sending', C.text4),
      MsgStatus.sent => (Icons.check_rounded, 'Sent', C.text4),
      MsgStatus.delivered => (Icons.done_all_rounded, 'Delivered', C.text3),
      MsgStatus.read => (Icons.done_all_rounded, 'Read', C.accent),
      MsgStatus.failed => (Icons.error_outline_rounded, 'Failed', C.warm),
    };
    return Padding(
      padding: EdgeInsets.only(top: tight ? 3 : 12),
      child: Column(
        crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxW),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: mine ? C.accentA(0.13) : C.s1,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: mine ? C.accentA(0.16) : C.border),
            ),
            child: Text(msg.text, style: Ty.bodyStrong.copyWith(fontSize: 15, height: 1.5)),
          ),
          if (showStatus)
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(fmtTime(msg.at), style: Ty.mono(size: 9.5, color: C.text4, ls: 0.3)),
                  const SizedBox(width: 6),
                  Icon(sIcon, size: 12, color: sColor),
                  const SizedBox(width: 3),
                  Text(sLabel, style: Ty.mono(size: 9.5, color: sColor, ls: 0.3)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────────── 28. Notes panel ─────────────────────────────

class NotesPanel extends StatefulWidget {
  final String client;
  final VoidCallback onClose;

  const NotesPanel({super.key, required this.client, required this.onClose});

  @override
  State<NotesPanel> createState() => _NotesPanelState();
}

class _NotesPanelState extends State<NotesPanel> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final notes = app.notes.where((n) => n.client == widget.client).toList().reversed.toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 12, 12),
              child: Row(
                children: [
                  const Icon(Icons.lock_rounded, size: 14, color: _NoteColors.ink),
                  const SizedBox(width: 8),
                  Expanded(child: Text('PRIVATE THERAPIST NOTES', style: Ty.mono(size: 10.5, color: _NoteColors.ink))),
                  IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close_rounded, size: 18, color: C.text3)),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 18),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: _NoteColors.ink.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(R.xs),
                border: Border.all(color: _NoteColors.edge),
              ),
              child: Row(
                children: [
                  const Icon(Icons.visibility_off_outlined, size: 13, color: _NoteColors.ink),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Never visible to ${widget.client}. Not part of the conversation.', style: Ty.tiny.copyWith(color: _NoteColors.ink))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: notes.isEmpty
                  ? Center(child: Text('No notes yet for this client.', style: Ty.tiny))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
                      itemCount: notes.length,
                      itemBuilder: (_, i) => _NoteCard(note: notes[i]),
                    ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: _NoteColors.edge))),
              child: Column(
                children: [
                  TextField(
                    controller: _c,
                    maxLines: 4,
                    minLines: 3,
                    onChanged: (_) => setState(() {}),
                    style: Ty.bodyStrong.copyWith(fontSize: 14, color: const Color(0xFFEDE6D6)),
                    decoration: InputDecoration(
                      hintText: 'Session notes…',
                      fillColor: Colors.black.withValues(alpha: 0.25),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.sm), borderSide: const BorderSide(color: _NoteColors.edge)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.sm), borderSide: BorderSide(color: _NoteColors.ink.withValues(alpha: 0.6))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(fmtTime(DateTime.now()), style: Ty.mono(size: 9.5, color: C.text4, ls: 0.3)),
                      const Spacer(),
                      Pressable(
                        onTap: _c.text.trim().isEmpty
                            ? null
                            : () {
                                app.addNote(widget.client, _c.text.trim());
                                _c.clear();
                                setState(() {});
                                showToast(context, 'Private note saved', icon: Icons.lock_rounded);
                              },
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 150),
                          opacity: _c.text.trim().isEmpty ? 0.4 : 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(color: _NoteColors.ink, borderRadius: BorderRadius.circular(R.sm)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.lock_rounded, size: 13, color: _NoteColors.bg),
                                const SizedBox(width: 6),
                                Text('Save note', style: Ty.button.copyWith(fontSize: 13.5, color: _NoteColors.bg)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(R.xs),
        border: const Border(left: BorderSide(color: _NoteColors.ink, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('PRIVATE NOTE', style: Ty.mono(size: 8.5, color: _NoteColors.ink)),
              const Spacer(),
              Text('${fmtRelativeDay(note.at)} · ${fmtTime(note.at)}', style: Ty.mono(size: 9, color: C.text4, ls: 0.3)),
            ],
          ),
          const SizedBox(height: 8),
          Text(note.text, style: Ty.small.copyWith(color: const Color(0xFFE5DECF), fontSize: 13.5, height: 1.55)),
        ],
      ),
    );
  }
}

// ───────────────────────────── 30. Close session ─────────────────────────────

class CloseSessionScreen extends StatefulWidget {
  final String nickname;

  const CloseSessionScreen({super.key, required this.nickname});

  @override
  State<CloseSessionScreen> createState() => _CloseSessionScreenState();
}

class _CloseSessionScreenState extends State<CloseSessionScreen> {
  final _msg = TextEditingController(
    text: 'It\'s been good talking with you. I\'m closing our conversation for now — you can always request support again whenever you need it. Take care.',
  );
  bool _loading = false;

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    app.closeClient(widget.nickname);
    if (widget.nickname == AppState.demoClient) app.setConv(ConvState.closed);
    showToast(context, 'Session closed');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              const TopBar(backIcon: Icons.close_rounded),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  children: [
                    const Label('Close session'),
                    const SizedBox(height: 10),
                    Text('End this conversation?', style: Ty.h1),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(children: [
                        const TextSpan(text: 'You\'re closing your conversation with '),
                        TextSpan(text: widget.nickname, style: Ty.mono(size: 14, color: C.text, ls: 0.2)),
                        const TextSpan(text: '.'),
                      ]),
                      style: Ty.body,
                    ),
                    const SizedBox(height: 24),
                    const SectionTitle('What happens next'),
                    const Surface(
                      child: Column(
                        children: [
                          _Step(1, 'The client sees a calm "conversation ended" screen with your closing message.'),
                          _Step(2, 'They can request support again and be matched with you or someone new.'),
                          _Step(3, 'History stays readable by the client for 30 days.'),
                          _Step(4, 'Your private notes stay with you. They\'re never shared.', last: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Field(label: 'Closing message · visible to client', controller: _msg, maxLines: 4),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  children: [
                    Btn.destructive('Close session', loading: _loading, onTap: _close),
                    const SizedBox(height: 8),
                    Btn.ghost('Keep conversation open', onTap: () => Navigator.of(context).pop()),
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

class _Step extends StatelessWidget {
  final int n;
  final String text;
  final bool last;

  const _Step(this.n, this.text, {this.last = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 28, child: Text('0$n', style: Ty.mono(size: 11, color: C.accent))),
          Expanded(child: Text(text, style: Ty.small.copyWith(color: C.text, fontSize: 13.5))),
        ],
      ),
    );
  }
}

// ───────────────────────────── Request reassignment ─────────────────────────────

class ReassignScreen extends StatefulWidget {
  final String nickname;

  const ReassignScreen({super.key, required this.nickname});

  @override
  State<ReassignScreen> createState() => _ReassignScreenState();
}

class _ReassignScreenState extends State<ReassignScreen> {
  static const reasons = ['Outside my specialization', 'Language preference', 'Caseload is full', 'Client requested a change', 'Other'];
  String? _reason;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              const TopBar(title: 'Request reassignment'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  children: [
                    Text('Hand over with care.', style: Ty.h1),
                    const SizedBox(height: 10),
                    Text(
                      'An admin will review and match ${widget.nickname} with another therapist. The client is told gently, and your conversation stays open until the handover.',
                      style: Ty.body,
                    ),
                    const SizedBox(height: 24),
                    const SectionTitle('Reason'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: reasons.map((r) => ChoiceChipX(label: r, selected: _reason == r, onTap: () => setState(() => _reason = r))).toList(),
                    ),
                    const SizedBox(height: 24),
                    const Field(label: 'Note to admin · optional', hint: 'Context that helps the next therapist (no session details)', maxLines: 3),
                    const SizedBox(height: 12),
                    Text('Private notes are not transferred.', style: Ty.tiny),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Btn(
                  'Send request',
                  loading: _loading,
                  onTap: _reason == null
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await Future.delayed(const Duration(milliseconds: 900));
                          if (!context.mounted) return;
                          showToast(context, 'Reassignment requested', icon: Icons.swap_horiz_rounded);
                          Navigator.of(context).pop();
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

// ───────────────────────────── Therapist account ─────────────────────────────

class TherapistAccount extends StatelessWidget {
  const TherapistAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final me = app.therapists.first;
    return SafeArea(
      child: Narrow(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text('Account', style: Ty.h1),
            const SizedBox(height: 22),
            Surface(
              child: Row(
                children: [
                  Monogram(me.initials, size: 56, presence: app.myPresence),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(me.name, style: Ty.title),
                        const SizedBox(height: 2),
                        Text(me.title, style: Ty.small.copyWith(fontSize: 13)),
                        const SizedBox(height: 8),
                        const Tag('Verified', icon: Icons.verified_outlined, color: C.accent, filled: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle('Public profile'),
            Group(children: [
              RowTile(icon: Icons.edit_outlined, title: 'Bio & approach', subtitle: 'Shown on your client-facing profile', onTap: () => _edit(context, me)),
              RowTile(icon: Icons.label_outline_rounded, title: 'Specializations', value: me.focus.join(', '), chevron: false),
              RowTile(icon: Icons.translate_rounded, title: 'Languages', value: me.languages.join(', '), chevron: false),
            ]),
            const SizedBox(height: 22),
            const SectionTitle('Work'),
            Group(children: [
              RowTile(icon: Icons.circle_outlined, title: 'Availability', value: app.myPresence.label, onTap: () => Navigator.of(context).push(fade(const AvailabilityScreen()))),
              const RowTile(icon: Icons.notifications_none_rounded, title: 'Notifications', value: 'Messages, assignments', chevron: false),
            ]),
            const SizedBox(height: 22),
            const SectionTitle('Security'),
            Group(children: [
              const RowTile(icon: Icons.verified_user_outlined, title: 'Two-step verification', value: 'On', chevron: false),
              const RowTile(icon: Icons.devices_outlined, title: 'Active devices', value: '2', chevron: false),
              RowTile(
                icon: Icons.logout_rounded,
                title: 'Sign out',
                titleColor: C.warm,
                onTap: () async {
                  final ok = await confirm(context, title: 'Sign out?', body: 'You\'ll be set to Offline and stop receiving notifications.', confirmLabel: 'Sign out');
                  if (ok && context.mounted) {
                    app.setMyPresence(Presence.offline);
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }

  void _edit(BuildContext context, Therapist me) {
    showSheet(
      context,
      label: 'Public profile',
      title: 'Bio & approach',
      builder: (ctx) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Field(label: 'Short introduction', controller: TextEditingController(text: me.intro), maxLines: 2),
            const SizedBox(height: 14),
            Field(label: 'Approach', controller: TextEditingController(text: me.approach), maxLines: 4),
            const SizedBox(height: 16),
            Btn('Save changes', onTap: () {
              Navigator.pop(ctx);
              showToast(context, 'Profile updated');
            }),
          ],
        ),
      ),
    );
  }
}
