import 'package:flutter/material.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'chat.dart';
import 'journal.dart';
import 'matching.dart';
import 'mood.dart';
import 'profile.dart';

class ClientShell extends StatefulWidget {
  final bool openChat;

  const ClientShell({super.key, this.openChat = false});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  late int _index = widget.openChat ? 1 : 0;

  void go(int i) {
    setState(() => _index = i);
    if (i == 1) app.markRead();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onTab: go),
      ChatScreen(inTab: true, onBack: () => go(0)),
      const JournalHomeScreen(),
      const MoodHistoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: ListenableBuilder(
        listenable: app,
        builder: (_, __) => _BottomNav(index: _index, onTap: go, chatBadge: app.unreadFromTherapist > 0 && _index != 1),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final bool chatBadge;

  const _BottomNav({required this.index, required this.onTap, required this.chatBadge});

  static const items = [
    (Icons.circle_outlined, Icons.circle, 'Home'),
    (Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, 'Chat'),
    (Icons.book_outlined, Icons.book_rounded, 'Journal'),
    (Icons.waves, Icons.waves, 'Mood'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: C.bg,
        border: Border(top: BorderSide(color: C.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Narrow(
            child: Row(
              children: List.generate(items.length, (i) {
                final (icon, activeIcon, label) = items[i];
                final active = i == index;
                return Expanded(
                  child: Pressable(
                    onTap: () => onTap(i),
                    scale: 0.92,
                    child: SizedBox(
                      height: 62,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 180),
                                child: i == 0
                                    ? _HomeGlyph(key: ValueKey(active), active: active)
                                    : Icon(active ? activeIcon : icon, key: ValueKey(active), size: 21, color: active ? C.accent : C.text3),
                              ),
                              if (i == 1 && chatBadge)
                                Positioned(
                                  right: -3,
                                  top: -1,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(color: C.accent, shape: BoxShape.circle, border: Border.all(color: C.bg, width: 1.5)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            style: Ty.tiny.copyWith(fontSize: 10.5, color: active ? C.text : C.text3, fontWeight: FontWeight.w500),
                            child: Text(label),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// Home icon in the brand's language: a ring, filled at the centre when active.
class _HomeGlyph extends StatelessWidget {
  final bool active;

  const _HomeGlyph({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? C.accent : C.text3;
    return SizedBox(
      width: 21,
      height: 21,
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 1.6)),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 6 : 3,
              height: active ? 6 : 3,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── 10. Home ─────────────────────────────

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onTab;

  const HomeScreen({super.key, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final t = app.assigned;
        return SafeArea(
          child: Narrow(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greeting(), style: Ty.h1),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.lock_outline_rounded, size: 12, color: C.text3),
                              const SizedBox(width: 6),
                              Text(app.nickname, style: Ty.mono(size: 12, color: C.text2, ls: 0.4)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconBtn(
                      Icons.notifications_none_rounded,
                      dot: true,
                      onTap: () => Navigator.of(context).push(fade(const NotificationsScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Conversation card
                _ConversationCard(therapist: t, onOpen: () => onTab(1)),
                const SizedBox(height: 28),

                // Today's mood
                const SectionTitle('Today\'s mood'),
                _TodayMood(onHistory: () => onTab(3)),
                const SizedBox(height: 28),

                // Journal
                SectionTitle('Journal', action: 'All entries', onAction: () => onTab(2)),
                _JournalPeek(),
                const SizedBox(height: 28),

                // Support
                const SectionTitle('Your support'),
                Group(children: [
                  RowTile(
                    icon: Icons.person_outline_rounded,
                    title: t.short,
                    subtitle: '${t.title} · ${t.focus.join(', ')}',
                    onTap: () => Navigator.of(context).push(fade(TherapistProfileScreen(therapist: t))),
                  ),
                  RowTile(
                    icon: Icons.shield_outlined,
                    title: 'Privacy & security',
                    subtitle: 'Who can see what',
                    onTap: () => Navigator.of(context).push(fade(const PrivacyCenterScreen())),
                  ),
                ]),
                const SizedBox(height: 16),

                // Emergency — present, never dominant
                Pressable(
                  onTap: () => Navigator.of(context).push(fade(const EmergencyScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(R.md),
                      border: Border.all(color: C.warmA(0.22)),
                      color: C.warmA(0.04),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.support_outlined, size: 18, color: C.warm),
                        const SizedBox(width: 12),
                        Expanded(child: Text('Need immediate support?', style: Ty.small.copyWith(color: C.text, fontSize: 14))),
                        const Icon(Icons.arrow_forward_rounded, size: 16, color: C.warm),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Center(
                  child: Text('ENCRYPTED · VISIBLE ONLY TO YOU AND ${t.short.toUpperCase()}', style: Ty.mono(size: 9, color: C.text4)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final Therapist therapist;
  final VoidCallback onOpen;

  const _ConversationCard({required this.therapist, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final t = therapist;
    final closed = app.conv == ConvState.closed;
    final last = app.messages.isEmpty ? null : app.messages.last;
    final unread = app.unreadFromTherapist;

    return Container(
      decoration: BoxDecoration(
        color: C.s1,
        borderRadius: BorderRadius.circular(R.lg),
        border: Border.all(color: C.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(right: -60, top: -60, child: SizedBox(width: 200, height: 200, child: DotGrid(spacing: 11, opacity: 0.12, focus: Alignment.center))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Label(closed ? 'Conversation ended' : 'Your conversation'),
                    const Spacer(),
                    if (!closed) const PrivacyTag(),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  closed ? 'Support is still here\nwhenever you need it.' : 'Your conversation is here\nwhen you\'re ready.',
                  style: Ty.h2,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Monogram(t.initials, size: 42, presence: closed ? null : t.presence),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.short, style: Ty.title.copyWith(fontSize: 15)),
                          const SizedBox(height: 2),
                          Text(
                            closed ? 'Session closed' : t.presence.label,
                            style: Ty.tiny.copyWith(color: closed ? C.text3 : t.presence.color),
                          ),
                        ],
                      ),
                    ),
                    if (unread > 0 && !closed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: C.accent, borderRadius: BorderRadius.circular(99)),
                        child: Text('$unread new', style: Ty.mono(size: 10, color: C.bg, ls: 0.3)),
                      ),
                  ],
                ),
                if (!closed) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(R.sm), border: Border.all(color: C.hairline)),
                    child: app.therapistTyping
                        ? Text('${t.short} is typing…', style: Ty.small.copyWith(color: C.accent, fontSize: 13))
                        : Text(
                            last == null ? 'No messages yet — say hello whenever you like.' : '${last.mine ? 'You: ' : ''}${last.text}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Ty.small.copyWith(fontSize: 13, color: unread > 0 ? C.text : C.text2),
                          ),
                  ),
                ],
                const SizedBox(height: 18),
                closed
                    ? Btn('Find another therapist', onTap: () => Navigator.of(context).push(fade(const FindingScreen(reassign: true))))
                    : Btn('Continue conversation', onTap: onOpen),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayMood extends StatelessWidget {
  final VoidCallback onHistory;

  const _TodayMood({required this.onHistory});

  @override
  Widget build(BuildContext context) {
    final m = app.todayMood;
    return Surface(
      onTap: () {
        if (m == null) {
          Navigator.of(context).push(fade(const MoodCheckInScreen()));
        } else {
          onHistory();
        }
      },
      child: Row(
        children: [
          MoodOrb(value: m?.value ?? 2, size: 44, dim: m == null),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m == null ? 'How are you feeling?' : moodLabels[m.value], style: Ty.title.copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(m == null ? 'A 10-second check-in' : 'Checked in at ${fmtTime(m.at)}', style: Ty.tiny),
              ],
            ),
          ),
          Row(
            children: List.generate(7, (i) {
              final recent = app.moods.length > 7 ? app.moods.sublist(app.moods.length - 7) : app.moods;
              final v = i < recent.length ? recent[i].value : -1;
              return Container(
                margin: const EdgeInsets.only(left: 3),
                width: 4,
                height: v < 0 ? 4 : 6 + v * 4.0,
                decoration: BoxDecoration(
                  color: v < 0 ? C.border : C.accentA(0.3 + v * 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _JournalPeek extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final e = app.journal.isEmpty ? null : app.journal.first;
    if (e == null) {
      return Surface(
        onTap: () => Navigator.of(context).push(fade(const JournalEditorScreen())),
        child: Row(
          children: [
            const Icon(Icons.edit_outlined, size: 18, color: C.text2),
            const SizedBox(width: 12),
            Expanded(child: Text('Write something', style: Ty.small.copyWith(color: C.text))),
            const Icon(Icons.add_rounded, size: 18, color: C.text3),
          ],
        ),
      );
    }
    return Surface(
      onTap: () => Navigator.of(context).push(fade(JournalDetailScreen(id: e.id))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Label(fmtRelativeDay(e.created)),
              const Spacer(),
              Pressable(
                onTap: () => Navigator.of(context).push(fade(const JournalEditorScreen())),
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded, size: 15, color: C.accent),
                    const SizedBox(width: 4),
                    Text('New', style: Ty.small.copyWith(color: C.accent, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (e.title.isNotEmpty) ...[Text(e.title, style: Ty.title.copyWith(fontSize: 15)), const SizedBox(height: 4)],
          Text(e.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: Ty.small),
        ],
      ),
    );
  }
}
