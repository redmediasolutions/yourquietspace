import 'package:flutter/material.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'matching.dart';
import 'onboarding.dart';

// ───────────────────────────── 20. Profile ─────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final t = app.assigned;
        return SafeArea(
          child: Narrow(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              children: [
                Text('Profile', style: Ty.h1),
                const SizedBox(height: 22),
                // Anonymous identity card
                Container(
                  decoration: BoxDecoration(
                    color: C.s1,
                    borderRadius: BorderRadius.circular(R.lg),
                    border: Border.all(color: C.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      const Positioned.fill(child: DotGrid(spacing: 12, opacity: 0.09, focus: Alignment.topRight)),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Monogram(app.nickname, size: 56, accent: true),
                                const Spacer(),
                                const PrivacyTag(text: 'Anonymous'),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(app.nickname, style: Ty.mono(size: 20, color: C.text, ls: 0.2, w: FontWeight.w500)),
                            const SizedBox(height: 6),
                            Text('Your only identity here. No name, email or number attached.', style: Ty.small.copyWith(fontSize: 13)),
                            const SizedBox(height: 18),
                            const Divider(),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                _meta('ID', '7F3A·92C1'),
                                _meta('Joined', '6 days ago'),
                                _meta('Age', app.ageRange ?? '—'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const SectionTitle('Support'),
                Group(children: [
                  RowTile(
                    icon: Icons.person_outline_rounded,
                    title: 'My therapist',
                    subtitle: '${t.name} · ${t.presence.label}',
                    onTap: () => Navigator.of(context).push(fade(TherapistProfileScreen(therapist: t))),
                  ),
                  RowTile(
                    icon: Icons.support_outlined,
                    title: 'Emergency information',
                    onTap: () => Navigator.of(context).push(fade(const EmergencyScreen())),
                  ),
                ]),
                const SizedBox(height: 22),
                const SectionTitle('Settings'),
                Group(children: [
                  RowTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy',
                    value: 'Private',
                    onTap: () => Navigator.of(context).push(fade(const PrivacyCenterScreen())),
                  ),
                  RowTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    onTap: () => Navigator.of(context).push(fade(const NotificationSettingsScreen())),
                  ),
                  RowTile(icon: Icons.book_outlined, title: 'Journal settings', onTap: () => _journalSettings(context)),
                  RowTile(icon: Icons.tune_rounded, title: 'App preferences', onTap: () => _appPrefs(context)),
                ]),
                const SizedBox(height: 22),
                const SectionTitle('Help'),
                Group(children: [
                  RowTile(icon: Icons.help_outline_rounded, title: 'Help & support', onTap: () => _help(context)),
                  RowTile(icon: Icons.bug_report_outlined, title: 'Report a problem', onTap: () => _reportProblem(context)),
                ]),
                const SizedBox(height: 22),
                Group(children: [
                  RowTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign out',
                    chevron: false,
                    onTap: () async {
                      final ok = await confirm(
                        context,
                        icon: Icons.key_outlined,
                        title: 'Sign out?',
                        body: 'You\'ll need your recovery code to sign back in as ${app.nickname}. Make sure you\'ve saved it in Privacy & security.',
                        confirmLabel: 'Sign out',
                      );
                      if (ok && context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(fade(const WelcomeScreen()), (_) => false);
                      }
                    },
                  ),
                ]),
                const SizedBox(height: 28),
                Center(child: Text('THERAPIST APP · v1.0.0', style: Ty.mono(size: 9, color: C.text4))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _meta(String k, String v) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label(k, size: 9),
            const SizedBox(height: 4),
            Text(v, style: Ty.mono(size: 12, color: C.text2, ls: 0.3)),
          ],
        ),
      );

  void _journalSettings(BuildContext context) {
    showSheet(
      context,
      label: 'Journal',
      title: 'Journal settings',
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => Group(children: [
          RowTile(
            icon: Icons.notifications_none_rounded,
            title: 'Evening reminder',
            subtitle: 'A gentle nudge at 9:30 PM',
            trailing: Switch(value: app.notifyJournal, onChanged: (v) => set(() => app.notifyJournal = v)),
          ),
          RowTile(
            icon: Icons.fingerprint_rounded,
            title: 'Lock journal',
            subtitle: 'Require Face ID / fingerprint to open',
            trailing: Switch(value: app.appLock, onChanged: (v) => set(() => app.appLock = v)),
          ),
          RowTile(icon: Icons.download_outlined, title: 'Export entries', subtitle: 'Plain text, encrypted ZIP', onTap: () {
            Navigator.pop(ctx);
            showToast(context, 'Export prepared', icon: Icons.download_outlined);
          }),
        ]),
      ),
    );
  }

  void _appPrefs(BuildContext context) {
    showSheet(
      context,
      label: 'Preferences',
      title: 'App preferences',
      builder: (_) => StatefulBuilder(
        builder: (ctx, set) => Group(children: [
          RowTile(
            icon: Icons.lock_outline_rounded,
            title: 'App lock',
            subtitle: 'Lock when the app is in the background',
            trailing: Switch(value: app.appLock, onChanged: (v) => set(() => app.appLock = v)),
          ),
          RowTile(
            icon: Icons.visibility_off_outlined,
            title: 'Hide notification previews',
            subtitle: 'Show "New message" instead of the text',
            trailing: Switch(value: app.hidePreviews, onChanged: (v) => set(() => app.hidePreviews = v)),
          ),
          const RowTile(icon: Icons.dark_mode_outlined, title: 'Appearance', value: 'Dark', chevron: false),
          const RowTile(icon: Icons.translate_rounded, title: 'Language', value: 'English', chevron: false),
        ]),
      ),
    );
  }

  void _help(BuildContext context) {
    const faqs = [
      ('Is my therapist licensed?', 'Every therapist is verified before joining — license, qualifications and an interview.'),
      ('Can I change therapists?', 'Yes, any time. Open the conversation menu and choose Report or block → End conversation, then find someone new.'),
      ('What if I lose access?', 'Use the recovery code in Privacy & security. Without it we can\'t restore an anonymous account — by design.'),
      ('Is this for emergencies?', 'No. If you\'re in danger, use Emergency support for immediate help.'),
    ];
    showSheet(
      context,
      label: 'Help',
      title: 'Help & support',
      builder: (_) => SingleChildScrollView(
        child: Column(
          children: [
            for (final (q, a) in faqs) _Expandable(title: q, body: a),
            const SizedBox(height: 14),
            Btn.secondary('Contact support', icon: Icons.mail_outline_rounded, onTap: () => showToast(context, 'Support will reply in-app')),
          ],
        ),
      ),
    );
  }

  void _reportProblem(BuildContext context) {
    showSheet(
      context,
      label: 'Feedback',
      title: 'Report a problem',
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Field(hint: 'What went wrong? Please don\'t include personal details.', maxLines: 4),
          const SizedBox(height: 10),
          Text('Includes app version and device type. No messages are attached.', style: Ty.tiny),
          const SizedBox(height: 16),
          Btn('Send report', onTap: () {
            Navigator.pop(ctx);
            showToast(context, 'Thanks — we\'ll look into it');
          }),
        ],
      ),
    );
  }
}

class _Expandable extends StatefulWidget {
  final String title;
  final String body;
  final IconData? icon;
  final Widget? trailing;

  const _Expandable({required this.title, required this.body, this.icon}) : trailing = null;

  @override
  State<_Expandable> createState() => _ExpandableState();
}

class _ExpandableState extends State<_Expandable> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.hairline))),
      child: Column(
        children: [
          Pressable(
            onTap: () => setState(() => _open = !_open),
            scale: 0.995,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  if (widget.icon != null) ...[Icon(widget.icon, size: 18, color: C.text2), const SizedBox(width: 14)],
                  Expanded(child: Text(widget.title, style: Ty.bodyStrong.copyWith(fontSize: 14.5, height: 1.3))),
                  if (widget.trailing != null) ...[widget.trailing!, const SizedBox(width: 10)],
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.expand_more_rounded, size: 18, color: C.text3),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: EdgeInsets.only(bottom: 16, left: widget.icon != null ? 32 : 0),
                    child: Align(alignment: Alignment.centerLeft, child: Text(widget.body, style: Ty.small)),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────── 21. Privacy center ─────────────────────────────

class PrivacyCenterScreen extends StatefulWidget {
  const PrivacyCenterScreen({super.key});

  @override
  State<PrivacyCenterScreen> createState() => _PrivacyCenterScreenState();
}

class _PrivacyCenterScreenState extends State<PrivacyCenterScreen> {
  bool _reveal = false;

  static const topics = [
    (Icons.visibility_off_outlined, 'Anonymous identity', 'You\'re known only by your nickname. We never ask for your real name, phone number, email or photo, and we don\'t read your contacts or location.'),
    (Icons.lock_outline_rounded, 'Private conversations', 'Your conversation exists between you and your assigned therapist. If you\'re reassigned, the previous conversation closes and stays readable only by you.'),
    (Icons.enhanced_encryption_outlined, 'Secure messaging', 'Messages are encrypted in transit (TLS 1.3) and at rest (AES-256). Attachments have location data stripped before upload.'),
    (Icons.storage_outlined, 'Data storage', 'Data is stored in India on encrypted servers. Mood check-ins and journal entries are tied to your anonymous ID only.'),
    (Icons.admin_panel_settings_outlined, 'Who can access conversations', 'Only you and your therapist. Admins can see that a conversation exists and its status — never its contents — unless you include messages in a safety report.'),
    (Icons.history_rounded, 'Session data', 'Closed conversations are kept for 30 days so you can reread them, then permanently deleted. You can delete sooner at any time.'),
    (Icons.key_outlined, 'Account recovery', 'Because your account is anonymous, your recovery code is the only way back in. Keep it somewhere safe — we can\'t reset it for you.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              const TopBar(title: 'Privacy & security'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  children: [
                    // Status hero
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(R.lg),
                        border: Border.all(color: C.accentA(0.22)),
                        color: C.accentA(0.04),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const PrivacyTag(),
                          const SizedBox(height: 14),
                          Text('Your conversations are visible only to you and your assigned therapist.', style: Ty.h2.copyWith(fontSize: 18)),
                          const SizedBox(height: 18),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 3.4,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            children: const [
                              _StatusCell('Encryption', 'On'),
                              _StatusCell('Identity', 'Anonymous'),
                              _StatusCell('Admin access', 'None'),
                              _StatusCell('Previews', 'Hidden'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const SectionTitle('Who can see what'),
                    const _AccessTable(),
                    const SizedBox(height: 28),
                    const SectionTitle('How it works'),
                    for (final (icon, title, body) in topics) _Expandable(icon: icon, title: title, body: body),
                    const SizedBox(height: 28),
                    const SectionTitle('Recovery code'),
                    Surface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    _reveal ? 'TIDE-4821-MOSS-0937' : '••••-••••-••••-••••',
                                    key: ValueKey(_reveal),
                                    style: Ty.mono(size: 16, color: C.text, ls: 1.2),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() => _reveal = !_reveal),
                                icon: Icon(_reveal ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: C.text2),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('The only way to restore this account. Store it offline.', style: Ty.tiny),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const SectionTitle('Your data'),
                    Group(children: [
                      RowTile(
                        icon: Icons.download_outlined,
                        title: 'Download my data',
                        subtitle: 'Messages, check-ins and journal',
                        onTap: () => showToast(context, 'Your export will be ready in a few minutes', icon: Icons.download_outlined),
                      ),
                      RowTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Delete account',
                        titleColor: C.warm,
                        onTap: () async {
                          final ok = await confirm(
                            context,
                            icon: Icons.delete_outline_rounded,
                            title: 'Delete your account?',
                            body:
                                'This permanently deletes ${app.nickname}, your conversations, mood check-ins and journal. Your therapist will be told the conversation ended — nothing more. This cannot be undone.',
                            confirmLabel: 'Delete everything',
                            destructive: true,
                          );
                          if (ok && context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(fade(const WelcomeScreen()), (_) => false);
                          }
                        },
                      ),
                    ]),
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

class _StatusCell extends StatelessWidget {
  final String k;
  final String v;

  const _StatusCell(this.k, this.v);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(R.xs), border: Border.all(color: C.border)),
      child: Row(
        children: [
          Container(width: 5, height: 5, decoration: const BoxDecoration(color: C.accent, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(k.toUpperCase(), overflow: TextOverflow.ellipsis, style: Ty.mono(size: 8.5, color: C.text3, ls: 0.8))),
          Text(v, style: Ty.small.copyWith(color: C.text, fontSize: 12)),
        ],
      ),
    );
  }
}

class _AccessTable extends StatelessWidget {
  const _AccessTable();

  static const rows = [
    ('Nickname', true, true, true),
    ('Messages', true, true, false),
    ('Concerns you shared', true, true, false),
    ('Mood check-ins', true, false, false),
    ('Journal', true, false, false),
    ('Real identity', false, false, false),
  ];

  @override
  Widget build(BuildContext context) {
    Widget head(String s) => Expanded(child: Center(child: Label(s, size: 9)));
    Widget cell(bool v) => Expanded(
          child: Center(
            child: v
                ? const Icon(Icons.check_rounded, size: 15, color: C.accent)
                : Container(width: 8, height: 1.4, color: C.text4),
          ),
        );
    return Container(
      decoration: BoxDecoration(color: C.s1, borderRadius: BorderRadius.circular(R.md), border: Border.all(color: C.border)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 12),
            child: Row(children: [const Expanded(flex: 3, child: SizedBox()), head('You'), head('Therapist'), head('Admin')]),
          ),
          const Divider(),
          for (final (label, you, th, ad) in rows) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 13, 8, 13),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(label, style: Ty.small.copyWith(color: C.text, fontSize: 13.5))),
                  cell(you),
                  cell(th),
                  cell(ad),
                ],
              ),
            ),
            if (label != rows.last.$1) const Divider(indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────────── Notification settings ─────────────────────────────

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              const TopBar(title: 'Notifications'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    const SectionTitle('Messages'),
                    Group(children: [
                      RowTile(
                        title: 'New messages',
                        subtitle: 'When your therapist replies',
                        trailing: Switch(value: app.notifyMessages, onChanged: (v) => setState(() => app.notifyMessages = v)),
                      ),
                      RowTile(
                        title: 'Hide previews',
                        subtitle: 'Lock screen shows "New message" only',
                        trailing: Switch(value: app.hidePreviews, onChanged: (v) => setState(() => app.hidePreviews = v)),
                      ),
                    ]),
                    const SizedBox(height: 22),
                    const SectionTitle('Reminders'),
                    Group(children: [
                      RowTile(
                        title: 'Mood check-in',
                        subtitle: 'Daily at 8:00 PM',
                        trailing: Switch(value: app.notifyMood, onChanged: (v) => setState(() => app.notifyMood = v)),
                      ),
                      RowTile(
                        title: 'Journal',
                        subtitle: 'Evenings at 9:30 PM',
                        trailing: Switch(value: app.notifyJournal, onChanged: (v) => setState(() => app.notifyJournal = v)),
                      ),
                    ]),
                    const SizedBox(height: 22),
                    // Push preview — shows exactly what appears on the lock screen
                    const SectionTitle('Lock screen preview'),
                    Surface(
                      color: C.s2,
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(9), border: Border.all(color: C.border)),
                            child: const Icon(Icons.circle_outlined, size: 16, color: C.text),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('THERAPIST', style: Ty.mono(size: 9.5, color: C.text3)),
                                    const Spacer(),
                                    Text('now', style: Ty.tiny),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('New message', style: Ty.bodyStrong.copyWith(fontSize: 14, height: 1.3)),
                                const SizedBox(height: 2),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    app.hidePreviews ? 'Open the app to read it.' : 'Dr. Maya: That\'s genuinely a good sign — noticing…',
                                    key: ValueKey(app.hidePreviews),
                                    style: Ty.small.copyWith(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

// ───────────────────────────── 22. Notification center ─────────────────────────────

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _icon(String k) => switch (k) {
        'message' => Icons.chat_bubble_outline_rounded,
        'available' => Icons.circle_outlined,
        'mood' => Icons.waves,
        'journal' => Icons.book_outlined,
        _ => Icons.shield_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final items = app.notifications;
    final today = items.where((n) => n.time.endsWith('m') || n.time.endsWith('h')).toList();
    final earlier = items.where((n) => !today.contains(n)).toList();
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              TopBar(title: 'Notifications', actions: [
                IconBtn(Icons.done_all_rounded, tooltip: 'Mark all read', onTap: () => showToast(context, 'All caught up')),
              ]),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: [
                    const SectionTitle('Today'),
                    Group(children: today.map((n) => _NotificationRow(n: n, icon: _icon(n.kind))).toList()),
                    const SizedBox(height: 24),
                    const SectionTitle('Earlier'),
                    Group(children: earlier.map((n) => _NotificationRow(n: n, icon: _icon(n.kind))).toList()),
                    const SizedBox(height: 20),
                    Center(child: Text('Previews are hidden on your lock screen', style: Ty.tiny.copyWith(color: C.text4))),
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

class _NotificationRow extends StatelessWidget {
  final AppNotification n;
  final IconData icon;

  const _NotificationRow({required this.n, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: n.unread ? C.accentA(0.1) : C.bg,
              border: Border.all(color: n.unread ? C.accentA(0.3) : C.border),
            ),
            child: Icon(icon, size: 15, color: n.unread ? C.accent : C.text3),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(n.title, style: Ty.bodyStrong.copyWith(fontSize: 14, height: 1.3, color: n.unread ? C.text : C.text2))),
                    Text(n.time, style: Ty.mono(size: 9.5, color: C.text4, ls: 0.3)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(n.body, style: Ty.small.copyWith(fontSize: 13)),
              ],
            ),
          ),
          if (n.unread)
            Container(
              margin: const EdgeInsets.only(left: 10, top: 6),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: C.accent, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────────── 19. Emergency support ─────────────────────────────

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  void _call(BuildContext context, String name, String number) async {
    final ok = await confirm(
      context,
      icon: Icons.call_outlined,
      title: 'Call $name?',
      body: 'This will open your phone app and dial $number. The call is not recorded or shared with the app.',
      confirmLabel: 'Call $number',
    );
    if (ok && context.mounted) showToast(context, 'Opening phone…', icon: Icons.call_outlined);
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
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: C.warmA(0.08), border: Border.all(color: C.warmA(0.3))),
                      child: const Icon(Icons.support_outlined, color: C.warm, size: 22),
                    ),
                    const SizedBox(height: 20),
                    Text('Need immediate\nsupport?', style: Ty.h1),
                    const SizedBox(height: 12),
                    Text(
                      'If you or someone else is in danger, or you\'re thinking about harming yourself, please contact emergency services now. This app isn\'t a replacement for emergency care.',
                      style: Ty.body,
                    ),
                    const SizedBox(height: 26),
                    Pressable(
                      onTap: () => _call(context, EmergencyConfig.primaryName, EmergencyConfig.primaryNumber),
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(color: C.warm, borderRadius: BorderRadius.circular(R.sm + 2)),
                        child: Row(
                          children: [
                            const Icon(Icons.call_rounded, color: C.bg, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text('Get immediate help', style: Ty.button.copyWith(color: C.bg, fontSize: 16))),
                            Text(EmergencyConfig.primaryNumber, style: Ty.mono(size: 16, color: C.bg, ls: 1, w: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const SectionTitle('Talk to someone now · ${EmergencyConfig.region}'),
                    Group(
                      children: [
                        for (final (name, number, desc) in EmergencyConfig.lines)
                          RowTile(
                            title: name,
                            subtitle: desc,
                            onTap: () => _call(context, name, number),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(number, style: Ty.mono(size: 12.5, color: C.text, ls: 0.4)),
                                const SizedBox(width: 10),
                                const Icon(Icons.call_outlined, size: 16, color: C.text3),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const SectionTitle('If you can, right now'),
                    Surface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final (i, s) in const [
                            (1, 'Move somewhere you feel safer, or near another person.'),
                            (2, 'Put distance between yourself and anything you could use to hurt yourself.'),
                            (3, 'Breathe slowly — in for 4, out for 6. Just a few times.'),
                            (4, 'Tell someone you trust how you\'re feeling, even in one line.'),
                          ])
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 28, child: Text('0$i', style: Ty.mono(size: 11, color: C.warm))),
                                  Expanded(child: Text(s, style: Ty.small.copyWith(color: C.text, fontSize: 14))),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Helpline details are configured for your region and kept up to date by our team.',
                      style: Ty.tiny.copyWith(color: C.text4),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Btn.ghost('Return to app', onTap: () => Navigator.of(context).pop()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
