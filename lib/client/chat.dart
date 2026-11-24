import 'package:flutter/material.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../core/visuals.dart';
import '../core/widgets.dart';
import 'matching.dart';
import 'profile.dart';

// ───────────────────────────── 11. Conversation ─────────────────────────────

class ChatScreen extends StatefulWidget {
  final bool inTab;
  final VoidCallback? onBack;

  const ChatScreen({super.key, this.inTab = false, this.onBack});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _emoji = false;
  int _lastCount = 0;

  static const _emojis = ['🙂', '🙏', '💙', '😔', '😮‍💨', '🌙', '✨', '👍', '😊', '🫶'];

  @override
  void initState() {
    super.initState();
    app.addListener(_onApp);
    _lastCount = app.messages.length;
    WidgetsBinding.instance.addPostFrameCallback((_) => _toEnd(jump: true));
  }

  void _onApp() {
    if (app.messages.length != _lastCount || app.therapistTyping) {
      _lastCount = app.messages.length;
      _toEnd();
    }
  }

  @override
  void dispose() {
    app.removeListener(_onApp);
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toEnd({bool jump = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final max = _scroll.position.maxScrollExtent;
      if (jump) {
        _scroll.jumpTo(max);
      } else {
        _scroll.animateTo(max, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
      }
    });
  }

  void _send([String? preset]) {
    final text = (preset ?? _input.text).trim();
    if (text.isEmpty) return;
    app.send(text);
    _input.clear();
    setState(() => _emoji = false);
  }

  @override
  Widget build(BuildContext context) {
    final body = ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final t = app.assigned;
        final closed = app.conv == ConvState.closed;
        return Column(
          children: [
            _Header(inTab: widget.inTab, onBack: widget.onBack),
            _StatusBanners(therapist: t),
            Expanded(child: _buildList(t)),
            if (closed) const _ClosedPanel() else _composer(t),
          ],
        );
      },
    );
    final content = SafeArea(bottom: !widget.inTab, child: Narrow(max: 720, child: body));
    return widget.inTab ? content : Scaffold(body: content);
  }

  Widget _buildList(Therapist t) {
    final msgs = app.messages;
    final conv = app.conv;

    if (msgs.isEmpty && !app.therapistTyping) {
      return _EmptyConversation(therapist: t, reassigned: conv == ConvState.reassigned, onPick: _send);
    }

    final items = <Widget>[];
    if (conv == ConvState.reassigned && app.previous != null) {
      items.add(_SystemNote(
        icon: Icons.swap_horiz_rounded,
        text: 'Your conversation moved to ${t.short}. Messages with ${app.previous!.short} stay private and closed.',
      ));
    }

    DateTime? lastDay;
    for (var i = 0; i < msgs.length; i++) {
      final m = msgs[i];
      final day = DateTime(m.at.year, m.at.month, m.at.day);
      if (lastDay == null || day != lastDay) {
        items.add(_DateSeparator(label: fmtRelativeDay(m.at)));
        lastDay = day;
      }
      if (app.unreadDividerAt == i) items.add(const _UnreadDivider());

      final prev = i > 0 ? msgs[i - 1] : null;
      final next = i < msgs.length - 1 ? msgs[i + 1] : null;
      final groupedWithPrev = prev != null && prev.mine == m.mine && m.at.difference(prev.at).inMinutes < 4;
      final lastInGroup = next == null || next.mine != m.mine || next.at.difference(m.at).inMinutes >= 4;
      final isLatestMine = m.mine && !msgs.skip(i + 1).any((x) => x.mine);

      items.add(_Bubble(
        key: ValueKey(m.id),
        msg: m,
        tight: groupedWithPrev,
        showMeta: lastInGroup || m.status == MsgStatus.failed || isLatestMine,
        showStatus: isLatestMine || m.status == MsgStatus.failed || m.status == MsgStatus.sending,
      ));
    }

    if (app.therapistTyping) items.add(const _TypingBubble());

    if (conv == ConvState.ending) {
      items.add(const _SystemNote(
        icon: Icons.hourglass_bottom_rounded,
        text: 'Dr. Maya is wrapping up this session. You can keep writing for a little while — take your time.',
      ));
    }

    return ListView(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: items,
    );
  }

  Widget _composer(Therapist t) {
    final canSend = _input.text.trim().isNotEmpty;
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.hairline))),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _emoji
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _emojis
                            .map((e) => Pressable(
                                  onTap: () {
                                    _input.text = '${_input.text}$e';
                                    _input.selection = TextSelection.collapsed(offset: _input.text.length);
                                    setState(() {});
                                  },
                                  scale: 0.85,
                                  child: Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text(e, style: const TextStyle(fontSize: 22)),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconBtn(Icons.add_rounded, size: 42, onTap: () => _attachSheet(context), tooltip: 'Attach'),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 42),
                  decoration: BoxDecoration(
                    color: C.s1,
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(color: C.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _input,
                          minLines: 1,
                          maxLines: 5,
                          onChanged: (_) => setState(() {}),
                          textCapitalization: TextCapitalization.sentences,
                          style: Ty.bodyStrong.copyWith(fontSize: 15, height: 1.4),
                          decoration: const InputDecoration(
                            hintText: 'Write something…',
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(16, 11, 4, 11),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => setState(() => _emoji = !_emoji),
                          icon: Icon(
                            _emoji ? Icons.keyboard_outlined : Icons.sentiment_satisfied_outlined,
                            size: 20,
                            color: C.text3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Pressable(
                onTap: canSend ? _send : null,
                scale: 0.9,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: canSend ? C.text : C.s2,
                    shape: BoxShape.circle,
                    border: Border.all(color: canSend ? C.text : C.border),
                  ),
                  child: Icon(Icons.arrow_upward_rounded, size: 20, color: canSend ? C.bg : C.text4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 10, color: C.text4),
              const SizedBox(width: 5),
              Text('ENCRYPTED · ONLY YOU AND ${t.short.toUpperCase()}', style: Ty.mono(size: 8.5, color: C.text4)),
            ],
          ),
        ],
      ),
    );
  }

  void _attachSheet(BuildContext context) {
    showSheet(
      context,
      label: 'Attach',
      title: 'Share a file',
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Group(children: [
            RowTile(icon: Icons.image_outlined, title: 'Photo', subtitle: 'From your library', onTap: () => _fakeAttach(ctx, 'Photo')),
            RowTile(icon: Icons.description_outlined, title: 'Document', subtitle: 'PDF, up to 10 MB', onTap: () => _fakeAttach(ctx, 'Document')),
          ]),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.lock_outline_rounded, size: 13, color: C.text3),
              const SizedBox(width: 8),
              Expanded(child: Text('Files are encrypted and visible only to you and your therapist. Location data is removed from photos.', style: Ty.tiny)),
            ],
          ),
        ],
      ),
    );
  }

  void _fakeAttach(BuildContext ctx, String kind) {
    Navigator.pop(ctx);
    showToast(context, 'File access needs permission', icon: Icons.folder_open_outlined);
  }
}

// ── Header ──

class _Header extends StatelessWidget {
  final bool inTab;
  final VoidCallback? onBack;

  const _Header({required this.inTab, this.onBack});

  @override
  Widget build(BuildContext context) {
    final t = app.assigned;
    final closed = app.conv == ConvState.closed;
    final status = closed
        ? 'Conversation ended'
        : app.therapistTyping
            ? 'typing…'
            : switch (t.presence) {
                Presence.online => 'Online',
                Presence.away => 'Away · replies within an hour',
                Presence.offline => 'Offline · last seen 42m ago',
              };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              IconBtn(Icons.chevron_left_rounded, onTap: onBack ?? () => Navigator.of(context).maybePop()),
              const SizedBox(width: 10),
              Expanded(
                child: Pressable(
                  onTap: () => Navigator.of(context).push(fade(TherapistProfileScreen(therapist: t))),
                  child: Row(
                    children: [
                      Monogram(t.initials, size: 38, presence: closed ? null : t.presence),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.short, style: Ty.title.copyWith(fontSize: 15)),
                            const SizedBox(height: 1),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                status,
                                key: ValueKey(status),
                                style: Ty.tiny.copyWith(
                                  color: app.therapistTyping ? C.accent : (closed ? C.text3 : t.presence.color),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconBtn(Icons.more_horiz_rounded, onTap: () => _menu(context)),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: C.hairline), bottom: BorderSide(color: C.hairline)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 11, color: C.accent),
              const SizedBox(width: 6),
              Text('PRIVATE CONVERSATION', style: Ty.mono(size: 9.5, color: C.accent)),
              Flexible(
                child: Text(
                  '  ·  YOU APPEAR AS ${app.nickname.toUpperCase()}',
                  overflow: TextOverflow.ellipsis,
                  style: Ty.mono(size: 9.5, color: C.text4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _menu(BuildContext context) {
    final t = app.assigned;
    showSheet(
      context,
      label: 'Conversation',
      builder: (ctx) {
        void close(VoidCallback then) {
          Navigator.pop(ctx);
          then();
        }

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Group(children: [
                RowTile(
                  icon: Icons.person_outline_rounded,
                  title: 'View ${t.short}\'s profile',
                  onTap: () => close(() => Navigator.of(context).push(fade(TherapistProfileScreen(therapist: t)))),
                ),
                RowTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & security',
                  onTap: () => close(() => Navigator.of(context).push(fade(const PrivacyCenterScreen()))),
                ),
                RowTile(
                  icon: Icons.support_outlined,
                  title: 'Emergency support',
                  onTap: () => close(() => Navigator.of(context).push(fade(const EmergencyScreen()))),
                ),
              ]),
              const SizedBox(height: 12),
              Group(children: [
                RowTile(
                  icon: Icons.flag_outlined,
                  title: 'Report or block',
                  titleColor: C.warm,
                  onTap: () => close(() => Navigator.of(context).push(fade(const ReportBlockScreen()))),
                ),
              ]),
              const SizedBox(height: 22),
              const Label('Preview states · demo'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip('Empty', () => close(() => app.setConv(ConvState.empty))),
                  _chip('Long history', () => close(app.loadHistory)),
                  _chip('Typing', () => close(() {
                        app.therapistTyping = true;
                        app.update();
                        Future.delayed(const Duration(seconds: 3), () {
                          app.therapistTyping = false;
                          app.update();
                        });
                      })),
                  _chip(app.networkOnline ? 'Go offline' : 'Reconnect', () => close(() => app.setNetwork(!app.networkOnline))),
                  _chip('Therapist online', () => close(() => app.setTherapistPresence(Presence.online))),
                  _chip('Therapist away', () => close(() => app.setTherapistPresence(Presence.away))),
                  _chip('Therapist offline', () => close(() => app.setTherapistPresence(Presence.offline))),
                  _chip('Unread', () => close(() {
                        app.unreadDividerAt = (app.messages.length - 2).clamp(0, app.messages.length);
                        app.update();
                      })),
                  _chip('Session ending', () => close(() => app.setConv(ConvState.ending))),
                  _chip('Closed', () => close(() {
                        app.setConv(ConvState.closed);
                        Navigator.of(context).push(fade(const SessionClosedScreen()));
                      })),
                  _chip('Reassigned', () => close(() => app.reassignTo(app.therapists.firstWhere((x) => x.id != app.assigned.id && x.presence == Presence.online)))),
                  _chip('Unavailable screen', () => close(() => Navigator.of(context).push(fade(const TherapistUnavailableScreen())))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(String label, VoidCallback onTap) => Pressable(
        onTap: onTap,
        scale: 0.95,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: C.bg,
            borderRadius: BorderRadius.circular(R.xs),
            border: Border.all(color: C.border),
          ),
          child: Text(label, style: Ty.mono(size: 10.5, color: C.text2, ls: 0.4)),
        ),
      );
}

// ── Status banners ──

class _StatusBanners extends StatelessWidget {
  final Therapist therapist;

  const _StatusBanners({required this.therapist});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (app.conv != ConvState.closed) {
      if (!app.networkOnline) {
        children.add(Banner2(
          icon: Icons.wifi_off_rounded,
          text: 'No connection. Reconnecting — messages will send when you\'re back.',
          spinner: true,
          action: 'Retry',
          onAction: () => app.setNetwork(true),
        ));
      }
      if (therapist.presence == Presence.offline) {
        children.add(Banner2(
          icon: Icons.nightlight_outlined,
          text: '${therapist.short} is offline. She\'ll see your messages when she\'s back.',
          action: 'Options',
          onAction: () => Navigator.of(context).push(fade(const TherapistUnavailableScreen())),
        ));
      } else if (therapist.presence == Presence.away) {
        children.add(Banner2(
          icon: Icons.schedule_rounded,
          color: C.away,
          text: '${therapist.short} is away right now — usually replies within an hour.',
        ));
      }
      if (app.conv == ConvState.ending) {
        children.add(const Banner2(icon: Icons.hourglass_bottom_rounded, color: C.accent, text: 'This session is ending soon.'));
      }
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      child: children.isEmpty
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                children: [
                  for (final c in children) Padding(padding: const EdgeInsets.only(bottom: 6), child: c),
                ],
              ),
            ),
    );
  }
}

// ── List pieces ──

class _DateSeparator extends StatelessWidget {
  final String label;

  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Label(label, size: 9.5, color: C.text4)),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class _UnreadDivider extends StatelessWidget {
  const _UnreadDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: C.accentA(0.35))),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Label('New messages', size: 9.5, color: C.accent)),
          Expanded(child: Container(height: 1, color: C.accentA(0.35))),
        ],
      ),
    );
  }
}

class _SystemNote extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SystemNote({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(R.sm),
          border: Border.all(color: C.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: C.text3),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: Ty.small.copyWith(fontSize: 13))),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Msg msg;
  final bool tight;
  final bool showMeta;
  final bool showStatus;

  const _Bubble({super.key, required this.msg, required this.tight, required this.showMeta, required this.showStatus});

  @override
  Widget build(BuildContext context) {
    final mine = msg.mine;
    final failed = msg.status == MsgStatus.failed;
    final sending = msg.status == MsgStatus.sending;
    final maxW = MediaQuery.sizeOf(context).width.clamp(0, 720) * 0.76;

    final bubble = AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: sending ? 0.6 : 1,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxW.toDouble()),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? (failed ? C.warmA(0.08) : C.accentA(0.13)) : C.s1,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: mine ? (failed ? C.warmA(0.35) : C.accentA(0.16)) : C.border),
        ),
        child: Text(msg.text, style: Ty.bodyStrong.copyWith(fontSize: 15, height: 1.5)),
      ),
    );

    Widget meta() {
      final parts = <Widget>[Text(fmtTime(msg.at), style: Ty.mono(size: 9.5, color: C.text4, ls: 0.3))];
      if (mine && showStatus) {
        final (IconData icon, String label, Color color) = switch (msg.status) {
          MsgStatus.sending => (Icons.schedule_rounded, 'Sending', C.text4),
          MsgStatus.sent => (Icons.check_rounded, 'Sent', C.text4),
          MsgStatus.delivered => (Icons.done_all_rounded, 'Delivered', C.text3),
          MsgStatus.read => (Icons.done_all_rounded, 'Read', C.accent),
          MsgStatus.failed => (Icons.error_outline_rounded, 'Not sent · Tap to retry', C.warm),
        };
        parts.addAll([
          const SizedBox(width: 6),
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(label, style: Ty.mono(size: 9.5, color: color, ls: 0.3)),
        ]);
      }
      return Padding(
        padding: const EdgeInsets.only(top: 5, left: 4, right: 4),
        child: Row(mainAxisSize: MainAxisSize.min, children: parts),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 6 * (1 - v)), child: child)),
      child: Padding(
        padding: EdgeInsets.only(top: tight ? 3 : 12),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            failed ? Pressable(onTap: () => app.retry(msg), child: bubble) : bubble,
            if (showMeta) failed ? Pressable(onTap: () => app.retry(msg), child: meta()) : meta(),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: C.s1,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: C.border),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final phase = (_c.value - i * 0.18) % 1.0;
                final lift = phase < 0.4 ? (phase < 0.2 ? phase / 0.2 : (0.4 - phase) / 0.2) : 0.0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: 6,
                  height: 6,
                  transform: Matrix4.translationValues(0, -3 * lift, 0),
                  decoration: BoxDecoration(
                    color: Color.lerp(C.text4, C.text, lift),
                    shape: BoxShape.circle,
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

class _EmptyConversation extends StatelessWidget {
  final Therapist therapist;
  final bool reassigned;
  final ValueChanged<String> onPick;

  const _EmptyConversation({required this.therapist, required this.reassigned, required this.onPick});

  static const starters = [
    'I\'m not sure where to start.',
    'I\'ve been feeling overwhelmed lately.',
    'How does this work?',
  ];

  @override
  Widget build(BuildContext context) {
    final t = therapist;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        if (reassigned && app.previous != null) ...[
          _SystemNote(
            icon: Icons.swap_horiz_rounded,
            text: 'Your conversation moved to ${t.short}. Messages with ${app.previous!.short} stay private and closed.',
          ),
          const SizedBox(height: 12),
        ],
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
                  child: Monogram(t.initials, size: 58, presence: t.presence),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('This is the start of your\nconversation with ${t.short}.', textAlign: TextAlign.center, style: Ty.h2),
        const SizedBox(height: 10),
        Text(
          'Say as much or as little as you like. ${t.short} sees you only as ${app.nickname}.',
          textAlign: TextAlign.center,
          style: Ty.small,
        ),
        const SizedBox(height: 28),
        const Center(child: Label('Not sure what to say?')),
        const SizedBox(height: 12),
        for (final s in starters)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Surface(
              onTap: () => onPick(s),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Expanded(child: Text(s, style: Ty.small.copyWith(color: C.text))),
                  const Icon(Icons.arrow_upward_rounded, size: 15, color: C.text3),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ClosedPanel extends StatelessWidget {
  const _ClosedPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(color: C.s1, border: Border(top: BorderSide(color: C.border))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('This conversation has ended.', style: Ty.title),
          const SizedBox(height: 4),
          Text('You can read it any time. Request support again whenever you need it.', textAlign: TextAlign.center, style: Ty.small),
          const SizedBox(height: 14),
          Btn('Find another therapist', height: 46, onTap: () => Navigator.of(context).push(fade(const FindingScreen(reassign: true)))),
        ],
      ),
    );
  }
}

// ───────────────────────────── 12. Session closed ─────────────────────────────

class SessionClosedScreen extends StatelessWidget {
  const SessionClosedScreen({super.key});

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
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeInOutCubic,
                builder: (_, v, __) => CustomPaint(size: const Size.square(120), painter: _ClosingRing(v)),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text('This conversation\nhas ended.', textAlign: TextAlign.center, style: Ty.h1),
                    const SizedBox(height: 12),
                    Text(
                      'Thank you for trusting ${t.short} with what you shared. You can read the conversation any time, and request support again whenever you need it.',
                      textAlign: TextAlign.center,
                      style: Ty.body,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Tag('History visible only to you', icon: Icons.lock_outline_rounded),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  children: [
                    Btn('Find another therapist', onTap: () => Navigator.of(context).pushReplacement(fade(const FindingScreen(reassign: true)))),
                    const SizedBox(height: 8),
                    Btn.ghost('Back to home', onTap: () => Navigator.of(context).popUntil((r) => r.isFirst)),
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

class _ClosingRing extends CustomPainter {
  final double v;

  _ClosingRing(this.v);

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 2;
    canvas.drawCircle(c, r, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = C.border);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -1.5708,
      6.2832 * v,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round
        ..color = C.text,
    );
    canvas.drawCircle(c, 4 + 2 * v, Paint()..color = C.accent.withValues(alpha: 0.4 + 0.6 * v));
  }

  @override
  bool shouldRepaint(covariant _ClosingRing old) => old.v != v;
}

// ───────────────────────────── 23. Report / block ─────────────────────────────

class ReportBlockScreen extends StatelessWidget {
  const ReportBlockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = app.assigned;
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: Column(
            children: [
              const TopBar(title: 'Report or block'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    Text('Something not right?', style: Ty.h1),
                    const SizedBox(height: 10),
                    Text(
                      'You\'re always in control of this conversation. Choose what feels right — nothing happens until you confirm.',
                      style: Ty.body,
                    ),
                    const SizedBox(height: 24),
                    _Option(
                      icon: Icons.flag_outlined,
                      title: 'Report ${t.short}',
                      body: 'Tell our safety team what happened. Your report is confidential — ${t.short} won\'t see who sent it.',
                      onTap: () => Navigator.of(context).push(fade(const ReportFormScreen())),
                    ),
                    const SizedBox(height: 10),
                    _Option(
                      icon: Icons.block_rounded,
                      title: 'Block ${t.short}',
                      body: 'She won\'t be able to message you, and this conversation will close. We\'ll help you find someone new.',
                      warm: true,
                      onTap: () async {
                        final ok = await confirm(
                          context,
                          icon: Icons.block_rounded,
                          title: 'Block ${t.short}?',
                          body:
                              '• ${t.short} won\'t be able to contact you again.\n• This conversation will close — you can still read it.\n• You won\'t be matched with her in the future.',
                          confirmLabel: 'Block',
                          destructive: true,
                        );
                        if (!ok || !context.mounted) return;
                        app.setConv(ConvState.closed);
                        showToast(context, '${t.short} has been blocked', icon: Icons.block_rounded);
                        Navigator.of(context).pushReplacement(fade(const SessionClosedScreen()));
                      },
                    ),
                    const SizedBox(height: 10),
                    _Option(
                      icon: Icons.logout_rounded,
                      title: 'End conversation',
                      body: 'Close this conversation without reporting anyone. You can start a new one any time.',
                      onTap: () async {
                        final ok = await confirm(
                          context,
                          icon: Icons.logout_rounded,
                          title: 'End this conversation?',
                          body: 'The conversation will close for both of you. Your history stays private and readable by you.',
                          confirmLabel: 'End conversation',
                          destructive: true,
                        );
                        if (!ok || !context.mounted) return;
                        app.setConv(ConvState.closed);
                        Navigator.of(context).pushReplacement(fade(const SessionClosedScreen()));
                      },
                    ),
                    const SizedBox(height: 24),
                    Banner2(
                      icon: Icons.support_outlined,
                      color: C.warm,
                      text: 'If you feel unsafe right now, emergency support is available.',
                      action: 'Open',
                      onAction: () => Navigator.of(context).push(fade(const EmergencyScreen())),
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

class _Option extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
  final bool warm;

  const _Option({required this.icon, required this.title, required this.body, required this.onTap, this.warm = false});

  @override
  Widget build(BuildContext context) {
    return Surface(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: warm ? C.warm : C.text),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Ty.title.copyWith(fontSize: 15, color: warm ? C.warm : C.text)),
                const SizedBox(height: 4),
                Text(body, style: Ty.small.copyWith(fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, size: 18, color: C.text4),
        ],
      ),
    );
  }
}

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  static const reasons = [
    'Unprofessional or dismissive',
    'Made me feel unsafe',
    'Asked for personal information',
    'Not responding',
    'Something else',
  ];
  String? _reason;
  bool _sending = false;
  bool _done = false;

  Future<void> _submit() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _sending = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Narrow(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _done ? _success(context) : _form(context),
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Column(
      key: const ValueKey('form'),
      children: [
        const TopBar(title: 'Report'),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Text('What happened?', style: Ty.h1),
              const SizedBox(height: 10),
              Text('Your report goes to our safety team only. Message content is not shared unless you choose to include it.', style: Ty.body),
              const SizedBox(height: 24),
              Group(
                children: reasons
                    .map((r) => RowTile(
                          title: r,
                          chevron: false,
                          onTap: () => setState(() => _reason = r),
                          trailing: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _reason == r ? C.accent : C.border, width: _reason == r ? 5 : 1.5),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              const Field(label: 'Details · optional', hint: 'Anything that would help us understand', maxLines: 4),
              const SizedBox(height: 12),
              Text('${app.assigned.short} will not be told who filed this report.', style: Ty.tiny),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Btn('Submit report', loading: _sending, onTap: _reason == null ? null : _submit),
        ),
      ],
    );
  }

  Widget _success(BuildContext context) {
    return Column(
      key: const ValueKey('done'),
      children: [
        const SizedBox(height: 60),
        const Spacer(),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: C.accentA(0.5)), color: C.accentA(0.08)),
          child: const Icon(Icons.check_rounded, color: C.accent, size: 28),
        ),
        const SizedBox(height: 24),
        Text('Report received.', style: Ty.h1),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Thank you for telling us. Our safety team will review it within 24 hours. You can keep your conversation open, or end it.',
            textAlign: TextAlign.center,
            style: Ty.body,
          ),
        ),
        const SizedBox(height: 14),
        Text('REF · R-1043', style: Ty.mono(color: C.text4)),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            children: [
              Btn('Done', onTap: () => Navigator.of(context).popUntil((r) => r.isFirst)),
              const SizedBox(height: 8),
              Btn.ghost('Find another therapist', onTap: () => Navigator.of(context).pushReplacement(fade(const FindingScreen(reassign: true)))),
            ],
          ),
        ),
      ],
    );
  }
}
