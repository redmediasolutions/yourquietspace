import 'package:flutter/material.dart';

import 'theme.dart';
import 'visuals.dart';
import 'widgets.dart';

/// Living reference of the component system and reusable states.
class DesignSystemScreen extends StatefulWidget {
  const DesignSystemScreen({super.key});

  @override
  State<DesignSystemScreen> createState() => _DesignSystemScreenState();
}

class _DesignSystemScreenState extends State<DesignSystemScreen> {
  int _seg = 0;
  bool _chip = true;
  bool _switch = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: 'Components'),
            Expanded(
              child: Narrow(
                max: 720,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
                  children: [
                    _h('Colour'),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Swatch('Background', C.bg, '#0B0B0D'),
                        _Swatch('Surface', C.s1, '#121214'),
                        _Swatch('Secondary', C.s2, '#18181B'),
                        _Swatch('Elevated', C.s3, '#202023'),
                        _Swatch('Border', C.border, '#27272A'),
                        _Swatch('Text', C.text, '#F5F5F5'),
                        _Swatch('Text 2', C.text2, '#A1A1AA'),
                        _Swatch('Muted', C.text3, '#71717A'),
                        _Swatch('Accent', C.accent, '#9DB7F5'),
                        _Swatch('Safety', C.warm, '#E08A76'),
                      ],
                    ),
                    _h('Type'),
                    Text('Display 34', style: Ty.display),
                    Text('Heading 26', style: Ty.h1),
                    Text('Heading 20', style: Ty.h2),
                    Text('Title 16', style: Ty.title),
                    Text('Body 15 — comfortable, readable, calm.', style: Ty.body),
                    Text('Small 13', style: Ty.small),
                    const SizedBox(height: 6),
                    const Label('Technical label · mono 10.5'),
                    _h('Buttons'),
                    const Btn('Primary'),
                    const SizedBox(height: 8),
                    const Btn.secondary('Secondary'),
                    const SizedBox(height: 8),
                    const Btn.ghost('Ghost'),
                    const SizedBox(height: 8),
                    const Btn.destructive('Destructive'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Btn('Loading', loading: _loading, onTap: () async {
                            setState(() => _loading = true);
                            await Future.delayed(const Duration(seconds: 2));
                            if (mounted) setState(() => _loading = false);
                          }),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: Btn('Disabled')),
                      ],
                    ),
                    _h('Inputs'),
                    const Field(label: 'Text', hint: 'Anonymous nickname'),
                    const SizedBox(height: 14),
                    const Field(hint: 'Search', prefix: Icons.search_rounded),
                    const SizedBox(height: 14),
                    const Field(label: 'Password', hint: '••••••••', password: true),
                    const SizedBox(height: 14),
                    const Field(label: 'Multiline', hint: 'Share whatever feels comfortable.', maxLines: 3),
                    const SizedBox(height: 14),
                    const Field(label: 'Error', hint: 'qm', error: 'At least 3 characters'),
                    _h('Navigation'),
                    Segmented(items: const ['Upcoming', 'Active', 'Closed'], index: _seg, onChanged: (i) => setState(() => _seg = i)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconBtn(Icons.chevron_left_rounded, onTap: () {}),
                        const SizedBox(width: 8),
                        IconBtn(Icons.notifications_none_rounded, dot: true, onTap: () {}),
                        const SizedBox(width: 12),
                        ChoiceChipX(label: 'Selectable', selected: _chip, onTap: () => setState(() => _chip = !_chip)),
                        const Spacer(),
                        Switch(value: _switch, onChanged: (v) => setState(() => _switch = v)),
                      ],
                    ),
                    _h('Status'),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Tag('Online', presence: Presence.online),
                        Tag('Away', presence: Presence.away),
                        Tag('Offline', presence: Presence.offline),
                        PrivacyTag(),
                        Tag('Verified', icon: Icons.verified_outlined, color: C.accent),
                        Tag('Unread', color: C.accent, filled: true),
                        Tag('Priority', color: C.warm, filled: true),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Row(
                      children: [
                        Monogram('DM', presence: Presence.online),
                        SizedBox(width: 10),
                        Monogram('QuietMind55', accent: true),
                        SizedBox(width: 10),
                        BrandMark(size: 36),
                      ],
                    ),
                    _h('Cards'),
                    Surface(
                      child: Row(
                        children: [
                          const Monogram('MR', size: 40, presence: Presence.online),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dr. Maya', style: Ty.title.copyWith(fontSize: 15)),
                                Text('Stress · Anxiety · Sleep', style: Ty.tiny),
                              ],
                            ),
                          ),
                          const PrivacyTag(text: 'Anonymous'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Group(children: [
                      RowTile(icon: Icons.shield_outlined, title: 'Grouped row', subtitle: 'With subtitle', chevron: false),
                      RowTile(icon: Icons.translate_rounded, title: 'Value row', value: 'English', chevron: false),
                    ]),
                    _h('Messaging'),
                    _bubble('Hi, I\'m Maya. There\'s no rush here.', false),
                    _bubble('Thank you. Work has been a lot.', true, meta: '9:14 PM  ✓✓ Read'),
                    _bubble('This one didn\'t go through.', true, failed: true, meta: 'Not sent · Tap to retry'),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Label('Yesterday', size: 9.5, color: C.text4)),
                        Expanded(child: Divider()),
                      ],
                    ),
                    _h('Feedback'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Btn.secondary('Toast', expand: false, height: 40, onTap: () => showToast(context, 'Saved to your journal')),
                        Btn.secondary('Bottom sheet', expand: false, height: 40, onTap: () {
                          showSheet(
                            context,
                            label: 'Sheet',
                            title: 'Bottom sheet',
                            builder: (_) => Text('Consistent chrome, handle and spacing across the app.', style: Ty.small),
                          );
                        }),
                        Btn.secondary('Modal', expand: false, height: 40, onTap: () {
                          confirm(context, title: 'Save check-in?', body: 'Only you can see your mood history.', confirmLabel: 'Save');
                        }),
                        Btn.secondary('Destructive', expand: false, height: 40, onTap: () {
                          confirm(
                            context,
                            icon: Icons.delete_outline_rounded,
                            title: 'Delete this entry?',
                            body: 'This can\'t be undone.',
                            confirmLabel: 'Delete',
                            destructive: true,
                          );
                        }),
                      ],
                    ),
                    _h('System states'),
                    const Label('Skeleton loading'),
                    const SizedBox(height: 10),
                    const Surface(
                      child: Row(
                        children: [
                          Skeleton(width: 40, height: 40, radius: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Skeleton(width: 140), SizedBox(height: 8), Skeleton(height: 10)],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Banner2(icon: Icons.wifi_off_rounded, text: 'No connection. Reconnecting…', spinner: true),
                    const SizedBox(height: 8),
                    const Banner2(icon: Icons.check_rounded, color: C.accent, text: 'Back online. Messages sent.'),
                    const SizedBox(height: 8),
                    Banner2(icon: Icons.error_outline_rounded, color: C.warm, text: 'Something went wrong loading messages.', action: 'Retry', onAction: () {}),
                    const SizedBox(height: 14),
                    // Permission request
                    Surface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notifications_none_rounded, color: C.text),
                          const SizedBox(height: 12),
                          Text('Know when your therapist replies', style: Ty.title),
                          const SizedBox(height: 6),
                          Text('Notifications never show message text — just "New message".', style: Ty.small),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(child: Btn.ghost('Not now', onTap: () {})),
                              const SizedBox(width: 8),
                              Expanded(child: Btn('Allow', height: 46, onTap: () => showToast(context, 'Notifications on'))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Label('Push notification'),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: C.s3.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(R.lg),
                        border: Border.all(color: C.border),
                      ),
                      child: Row(
                        children: [
                          const BrandMark(size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('New message', style: Ty.bodyStrong.copyWith(fontSize: 14, height: 1.3)),
                                Text('Open the app to read it.', style: Ty.small.copyWith(fontSize: 13)),
                              ],
                            ),
                          ),
                          Text('now', style: Ty.tiny),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Surface(
                      child: EmptyState(
                        icon: Icons.inbox_outlined,
                        code: 'Empty',
                        title: 'Nothing here yet',
                        body: 'Empty states explain what will appear and offer one next step.',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Surface(
                      child: EmptyState(
                        icon: Icons.cloud_off_outlined,
                        code: 'Error · 503',
                        title: 'We couldn\'t load this',
                        body: 'Your data is safe. Try again in a moment.',
                        action: 'Try again',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _h(String s) => Padding(
        padding: const EdgeInsets.only(top: 36, bottom: 14),
        child: Row(
          children: [
            Label(s, color: C.text2),
            const SizedBox(width: 12),
            const Expanded(child: Divider()),
          ],
        ),
      );

  Widget _bubble(String text, bool mine, {bool failed = false, String? meta}) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: mine ? (failed ? C.warmA(0.08) : C.accentA(0.13)) : C.s1,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: mine ? (failed ? C.warmA(0.35) : C.accentA(0.16)) : C.border),
              ),
              child: Text(text, style: Ty.bodyStrong),
            ),
            if (meta != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: Text(meta, style: Ty.mono(size: 9.5, color: failed ? C.warm : C.text4, ls: 0.3)),
              ),
          ],
        ),
      );
}

class _Swatch extends StatelessWidget {
  final String name;
  final Color color;
  final String hex;

  const _Swatch(this.name, this.color, this.hex);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(R.xs), border: Border.all(color: C.border)),
          ),
          const SizedBox(height: 6),
          Text(name, style: Ty.small.copyWith(color: C.text, fontSize: 12)),
          Text(hex, style: Ty.mono(size: 9.5, color: C.text4, ls: 0.4)),
        ],
      ),
    );
  }
}
