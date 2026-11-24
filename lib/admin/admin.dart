import 'package:flutter/material.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../core/visuals.dart';
import '../core/widgets.dart';

enum _Section { overview, therapists, clients, assignments, reports, settings }

extension on _Section {
  String get label => switch (this) {
        _Section.overview => 'Overview',
        _Section.therapists => 'Therapists',
        _Section.clients => 'Clients',
        _Section.assignments => 'Assignments',
        _Section.reports => 'Reports',
        _Section.settings => 'Settings',
      };

  IconData get icon => switch (this) {
        _Section.overview => Icons.grid_view_outlined,
        _Section.therapists => Icons.badge_outlined,
        _Section.clients => Icons.visibility_off_outlined,
        _Section.assignments => Icons.swap_horiz_rounded,
        _Section.reports => Icons.flag_outlined,
        _Section.settings => Icons.tune_rounded,
      };
}

class _Assignment {
  final String client;
  String therapist;
  String status; // Pending | Active | Reassign requested
  final String date;

  _Assignment(this.client, this.therapist, this.status, this.date);
}

final _assignments = <_Assignment>[
  _Assignment('NightOwl_08', '—', 'Pending', '4 Nov, 18:02'),
  _Assignment('GreyFog12', '—', 'Pending', '4 Nov, 14:20'),
  _Assignment('PaperBoat3', 'Dr. Ishaan Varma', 'Reassign requested', '21 Oct'),
  _Assignment('QuietMind55', 'Dr. Maya Raman', 'Active', '29 Oct'),
  _Assignment('StillWater21', 'Dr. Maya Raman', 'Active', '14 Oct'),
  _Assignment('Ember_Lane', 'Leah Fernandes', 'Closed', '2 Sep'),
];

// ───────────────────────────── Shell ─────────────────────────────

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  _Section _s = _Section.overview;
  final _scaffold = GlobalKey<ScaffoldState>();

  void _go(_Section s) {
    setState(() => _s = s);
    if (_scaffold.currentState?.isDrawerOpen ?? false) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= 1000;
      final page = ListenableBuilder(
        listenable: app,
        builder: (_, __) => switch (_s) {
          _Section.overview => _Overview(go: _go),
          _Section.therapists => const _Therapists(),
          _Section.clients => const _Clients(),
          _Section.assignments => const _Assignments(),
          _Section.reports => const _Reports(),
          _Section.settings => const _Settings(),
        },
      );
      final sidebar = _Sidebar(current: _s, onTap: _go);

      return Scaffold(
        key: _scaffold,
        backgroundColor: C.bg,
        drawer: wide ? null : Drawer(backgroundColor: C.bg, width: 260, child: sidebar),
        body: SafeArea(
          child: Row(
            children: [
              if (wide) SizedBox(width: 248, child: sidebar),
              if (wide) const VerticalDivider(width: 1, color: C.hairline),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: C.hairline))),
                      child: Row(
                        children: [
                          if (!wide) ...[
                            IconBtn(Icons.menu_rounded, size: 36, onTap: () => _scaffold.currentState?.openDrawer()),
                            const SizedBox(width: 12),
                          ],
                          Text(_s.label, style: Ty.title),
                          const Spacer(),
                          if (box.maxWidth > 640)
                            SizedBox(
                              width: 240,
                              height: 36,
                              child: TextField(
                                style: Ty.small.copyWith(color: C.text),
                                decoration: InputDecoration(
                                  hintText: 'Search nickname or therapist',
                                  hintStyle: Ty.small.copyWith(color: C.text4),
                                  prefixIcon: const Icon(Icons.search_rounded, size: 16, color: C.text4),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          const SizedBox(width: 12),
                          const Monogram('AD', size: 32),
                        ],
                      ),
                    ),
                    Expanded(child: page),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Sidebar extends StatelessWidget {
  final _Section current;
  final ValueChanged<_Section> onTap;

  const _Sidebar({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final newReports = app.reports.where((r) => r.status == ReportStatus.fresh).length;
    final pending = _assignments.where((a) => a.status != 'Active' && a.status != 'Closed').length;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const Wordmark(size: 13),
                  const SizedBox(width: 8),
                  Text('ADMIN', style: Ty.mono(size: 9, color: C.text4)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            for (final s in _Section.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Pressable(
                  onTap: () => onTap(s),
                  scale: 0.98,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: s == current ? C.s2 : Colors.transparent,
                      borderRadius: BorderRadius.circular(R.xs),
                      border: Border.all(color: s == current ? C.border : Colors.transparent),
                    ),
                    child: Row(
                      children: [
                        Icon(s.icon, size: 17, color: s == current ? C.text : C.text3),
                        const SizedBox(width: 12),
                        Expanded(child: Text(s.label, style: Ty.small.copyWith(color: s == current ? C.text : C.text2, fontSize: 13.5))),
                        if (s == _Section.reports && newReports > 0) _Count(newReports, warm: true),
                        if (s == _Section.assignments && pending > 0) _Count(pending),
                      ],
                    ),
                  ),
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(R.sm),
                border: Border.all(color: C.accentA(0.2)),
                color: C.accentA(0.04),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 13, color: C.accent),
                      SizedBox(width: 6),
                      Label('Privacy mode', size: 9, color: C.accent),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Message content is never shown in the admin console.', style: Ty.tiny.copyWith(height: 1.45)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Pressable(
              onTap: () => Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 15, color: C.text3),
                    const SizedBox(width: 10),
                    Text('Exit admin', style: Ty.small.copyWith(fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  final int n;
  final bool warm;

  const _Count(this.n, {this.warm = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: (warm ? C.warm : C.accent).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text('$n', style: Ty.mono(size: 9.5, color: warm ? C.warm : C.accent, ls: 0)),
    );
  }
}

// ───────────────────────────── Page scaffold ─────────────────────────────

class _Page extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? action;

  const _Page({required this.title, this.subtitle, required this.children, this.action});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Ty.h1.copyWith(fontSize: 24)),
                  if (subtitle != null) ...[const SizedBox(height: 6), Text(subtitle!, style: Ty.small)],
                ],
              ),
            ),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }
}

/// Minimal table: hairline rows, mono headers, horizontal scroll when narrow.
class _Table extends StatelessWidget {
  final List<(String, int)> columns;
  final List<List<Widget>> rows;
  final double minWidth;

  const _Table({required this.columns, required this.rows}) : minWidth = 820;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: C.s1, borderRadius: BorderRadius.circular(R.md), border: Border.all(color: C.border)),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(builder: (context, box) {
        final w = box.maxWidth < minWidth ? minWidth : box.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: w,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  color: C.s2,
                  child: Row(
                    children: [for (final (label, flex) in columns) Expanded(flex: flex, child: Label(label, size: 9))],
                  ),
                ),
                for (var i = 0; i < rows.length; i++) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Row(
                      children: [
                        for (var j = 0; j < columns.length; j++)
                          Expanded(flex: columns[j].$2, child: Align(alignment: Alignment.centerLeft, child: rows[i][j])),
                      ],
                    ),
                  ),
                ],
                if (rows.isEmpty)
                  const Padding(padding: EdgeInsets.all(24), child: EmptyState(icon: Icons.inbox_outlined, title: 'Nothing here', body: 'No records match.')),
              ],
            ),
          ),
        );
      }),
    );
  }
}

Widget _cellText(String s, {Color color = C.text2, bool mono = false}) => Text(
      s,
      overflow: TextOverflow.ellipsis,
      style: mono ? Ty.mono(size: 12, color: color, ls: 0.2) : Ty.small.copyWith(color: color, fontSize: 13),
    );

Widget _status(String s) {
  final color = switch (s) {
    'Active' || 'Online' => C.online,
    'Pending' || 'New' || 'Waiting' => C.accent,
    'Reassign requested' || 'Reviewing' || 'Away' => C.away,
    'Disabled' => C.warm,
    _ => C.text3,
  };
  return Tag(s, color: color, filled: true);
}

// ───────────────────────────── 31. Overview ─────────────────────────────

class _Overview extends StatelessWidget {
  final ValueChanged<_Section> go;

  const _Overview({required this.go});

  @override
  Widget build(BuildContext context) {
    final activeT = app.therapists.where((t) => t.enabled && t.presence != Presence.offline).length;
    final pending = _assignments.where((a) => a.status == 'Pending' || a.status == 'Reassign requested').toList();
    final openReports = app.reports.where((r) => r.status != ReportStatus.resolved).toList();

    final metrics = [
      ('Active therapists', '$activeT', 'of ${app.therapists.length}', _Section.therapists),
      ('Active clients', '128', '+6 this week', _Section.clients),
      ('Open conversations', '94', 'avg reply 11 min', _Section.clients),
      ('Pending assignments', '${pending.length}', 'oldest 4h', _Section.assignments),
      ('Reports', '${openReports.length}', '${app.reports.where((r) => r.status == ReportStatus.fresh).length} new', _Section.reports),
    ];

    return _Page(
      title: 'Overview',
      subtitle: fmtDate(DateTime.now()),
      children: [
        LayoutBuilder(builder: (context, box) {
          final cols = box.maxWidth > 1100 ? 5 : (box.maxWidth > 700 ? 3 : 2);
          final itemW = (box.maxWidth - (cols - 1) * 12) / cols;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (label, value, sub, target) in metrics)
                SizedBox(
                  width: itemW,
                  child: Surface(
                    onTap: () => go(target),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Label(label, size: 9),
                        const SizedBox(height: 14),
                        Text(value, style: Ty.mono(size: 28, color: C.text, ls: -0.5, w: FontWeight.w400)),
                        const SizedBox(height: 4),
                        Text(sub, style: Ty.tiny),
                      ],
                    ),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (context, box) {
          final wide = box.maxWidth > 860;
          final attention = _Panel(
            title: 'Needs attention',
            child: Column(
              children: [
                for (final a in pending)
                  RowTile(
                    icon: Icons.swap_horiz_rounded,
                    title: a.client,
                    subtitle: a.status == 'Pending' ? 'Waiting for a therapist · ${a.date}' : 'Reassignment requested by ${a.therapist}',
                    onTap: () => go(_Section.assignments),
                  ),
                for (final r in openReports.take(2))
                  RowTile(
                    icon: Icons.flag_outlined,
                    titleColor: r.status == ReportStatus.fresh ? C.warm : null,
                    title: '${r.id} · ${r.reason}',
                    subtitle: '${r.subject} · ${r.when}',
                    onTap: () => go(_Section.reports),
                  ),
              ],
            ),
          );
          final availability = _Panel(
            title: 'Therapist availability',
            child: Column(
              children: [
                for (final t in app.therapists)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    child: Row(
                      children: [
                        StatusDot(t.presence, size: 6),
                        const SizedBox(width: 6),
                        Expanded(child: Text(t.name, style: Ty.small.copyWith(color: C.text, fontSize: 13.5))),
                        Text('${t.activeClients} clients', style: Ty.mono(size: 10.5, color: C.text3, ls: 0.3)),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: 60,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: t.activeClients / 12,
                              minHeight: 3,
                              backgroundColor: C.s3,
                              color: t.activeClients >= 11 ? C.away : C.text3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
          return wide
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: attention), const SizedBox(width: 12), Expanded(child: availability)])
              : Column(children: [attention, const SizedBox(height: 12), availability]);
        }),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;

  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: C.s1, borderRadius: BorderRadius.circular(R.md), border: Border.all(color: C.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 10), child: Label(title)),
          const Divider(),
          child,
        ],
      ),
    );
  }
}

// ───────────────────────────── 32. Therapists ─────────────────────────────

class _Therapists extends StatelessWidget {
  const _Therapists();

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Therapists',
      subtitle: '${app.therapists.length} verified therapists',
      action: Btn('Invite therapist', icon: Icons.add_rounded, expand: false, height: 40, onTap: () => showToast(context, 'Invite link copied')),
      children: [
        _Table(
          columns: const [('Therapist', 4), ('Specialization', 3), ('Availability', 2), ('Active clients', 2), ('Status', 2), ('', 2)],
          rows: app.therapists.map((t) {
            return <Widget>[
              Row(
                children: [
                  Monogram(t.initials, size: 32),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.name, overflow: TextOverflow.ellipsis, style: Ty.small.copyWith(color: C.text, fontSize: 13.5)),
                        Text(t.title, overflow: TextOverflow.ellipsis, style: Ty.tiny),
                      ],
                    ),
                  ),
                ],
              ),
              _cellText(t.focus.join(', ')),
              Row(children: [StatusDot(t.presence, size: 6), Text(t.presence.label, style: Ty.small.copyWith(fontSize: 13))]),
              _cellText('${t.activeClients} / 12', mono: true),
              _status(t.enabled ? 'Active' : 'Disabled'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconAction(Icons.visibility_outlined, 'View', () => _view(context, t)),
                  _iconAction(Icons.edit_outlined, 'Edit', () => showToast(context, 'Editing ${t.short}')),
                  _iconAction(
                    t.enabled ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                    t.enabled ? 'Disable' : 'Enable',
                    () async {
                      if (!t.enabled) {
                        t.enabled = true;
                        app.update();
                        return;
                      }
                      final ok = await confirm(
                        context,
                        icon: Icons.block_rounded,
                        title: 'Disable ${t.name}?',
                        body: 'They\'ll be signed out and hidden from matching. Their ${t.activeClients} active clients will be queued for reassignment and notified gently.',
                        confirmLabel: 'Disable therapist',
                        destructive: true,
                      );
                      if (ok) {
                        t.enabled = false;
                        app.update();
                      }
                    },
                    warm: t.enabled,
                  ),
                ],
              ),
            ];
          }).toList(),
        ),
      ],
    );
  }

  void _view(BuildContext context, Therapist t) {
    showSheet(
      context,
      label: 'Therapist',
      title: t.name,
      builder: (_) => Group(children: [
        RowTile(title: 'Title', value: t.title, chevron: false),
        RowTile(title: 'Experience', value: '${t.years} years', chevron: false),
        RowTile(title: 'Languages', value: t.languages.join(', '), chevron: false),
        RowTile(title: 'Response time', value: t.response.replaceAll('Usually ', ''), chevron: false),
        RowTile(title: 'Last active', value: t.lastActive, chevron: false),
        const RowTile(title: 'License', value: 'RCI · verified 12 Mar 2026', chevron: false),
      ]),
    );
  }
}

Widget _iconAction(IconData icon, String tip, VoidCallback onTap, {bool warm = false}) => Tooltip(
      message: tip,
      child: Pressable(
        onTap: onTap,
        scale: 0.9,
        child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 17, color: warm ? C.warm : C.text3)),
      ),
    );

// ───────────────────────────── 33. Clients ─────────────────────────────

class _Clients extends StatelessWidget {
  const _Clients();

  @override
  Widget build(BuildContext context) {
    final created = ['29 Oct 2026', '4 Nov 2026', '14 Oct 2026', '21 Oct 2026', '4 Nov 2026', '2 Sep 2026'];
    return _Page(
      title: 'Clients',
      subtitle: 'Anonymous identifiers only',
      children: [
        const Banner2(
          icon: Icons.lock_outline_rounded,
          color: C.accent,
          text: 'Clients are shown by nickname. Real identity is never collected, and conversation content is not accessible here.',
        ),
        const SizedBox(height: 14),
        _Table(
          columns: const [('Nickname', 3), ('Status', 2), ('Assigned therapist', 3), ('Created', 2), ('Conversation', 2), ('', 1)],
          rows: [
            for (var i = 0; i < app.clients.length; i++)
              () {
                final c = app.clients[i];
                return <Widget>[
                  Row(children: [Monogram(c.nickname, size: 28), const SizedBox(width: 10), Flexible(child: _cellText(c.nickname, color: C.text, mono: true))]),
                  _status(c.status == ClientStatus.closed ? 'Inactive' : 'Active'),
                  _cellText(c.status == ClientStatus.waiting ? '— Unassigned' : c.assignedTo),
                  _cellText(created[i % created.length], mono: true, color: C.text3),
                  _status(switch (c.status) {
                    ClientStatus.waiting => 'Waiting',
                    ClientStatus.active => 'Open',
                    ClientStatus.closed => 'Closed',
                  }),
                  _iconAction(Icons.more_horiz_rounded, 'Actions', () {
                    showSheet(
                      context,
                      label: c.nickname,
                      builder: (ctx) => Group(children: [
                        RowTile(icon: Icons.swap_horiz_rounded, title: 'Reassign therapist', onTap: () {
                          Navigator.pop(ctx);
                          _pickTherapist(context, c.nickname);
                        }),
                        RowTile(icon: Icons.pause_circle_outline_rounded, title: 'Suspend account', titleColor: C.warm, onTap: () async {
                          Navigator.pop(ctx);
                          final ok = await confirm(
                            context,
                            icon: Icons.pause_circle_outline_rounded,
                            title: 'Suspend ${c.nickname}?',
                            body: 'They won\'t be able to send messages until reinstated. Use only after a safety review.',
                            confirmLabel: 'Suspend',
                            destructive: true,
                          );
                          if (ok && context.mounted) showToast(context, '${c.nickname} suspended');
                        }),
                      ]),
                    );
                  }),
                ];
              }(),
          ],
        ),
      ],
    );
  }
}

void _pickTherapist(BuildContext context, String client, [_Assignment? a]) {
  showSheet(
    context,
    label: 'Assign',
    title: 'Choose a therapist for $client',
    builder: (ctx) => SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Group(
            children: app.therapists.where((t) => t.enabled).map((t) {
              return RowTile(
                title: t.name,
                subtitle: '${t.focus.join(', ')} · ${t.activeClients}/12 clients',
                trailing: Tag(t.presence.label, presence: t.presence),
                onTap: () {
                  Navigator.pop(ctx);
                  if (a != null) {
                    a.therapist = t.name;
                    a.status = 'Active';
                    app.update();
                  }
                  showToast(context, '$client assigned to ${t.short}', icon: Icons.swap_horiz_rounded);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text('The client is notified gently. Previous conversation content is not transferred.', style: Ty.tiny),
        ],
      ),
    ),
  );
}

// ───────────────────────────── 35. Assignments ─────────────────────────────

class _Assignments extends StatelessWidget {
  const _Assignments();

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Assignments',
      subtitle: 'Match clients with available therapists',
      action: Btn.secondary('Auto-assign pending', icon: Icons.bolt_outlined, expand: false, height: 40, onTap: () {
        for (final a in _assignments.where((x) => x.status == 'Pending')) {
          a.therapist = 'Sana Qureshi';
          a.status = 'Active';
        }
        app.update();
        showToast(context, 'Pending clients matched', icon: Icons.bolt_outlined);
      }),
      children: [
        _Table(
          columns: const [('Client', 3), ('Therapist', 3), ('Status', 3), ('Assigned', 2), ('', 2)],
          rows: _assignments.map((a) {
            final actionable = a.status != 'Closed';
            return <Widget>[
              _cellText(a.client, color: C.text, mono: true),
              _cellText(a.therapist, color: a.therapist == '—' ? C.text4 : C.text2),
              _status(a.status),
              _cellText(a.date, mono: true, color: C.text3),
              actionable
                  ? Btn.secondary(
                      a.status == 'Pending' ? 'Assign' : 'Reassign',
                      expand: false,
                      height: 32,
                      onTap: () => _pickTherapist(context, a.client, a),
                    )
                  : const SizedBox(),
            ];
          }).toList(),
        ),
      ],
    );
  }
}

// ───────────────────────────── 34. Reports ─────────────────────────────

class _Reports extends StatefulWidget {
  const _Reports();

  @override
  State<_Reports> createState() => _ReportsState();
}

class _ReportsState extends State<_Reports> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final list = app.reports.where((r) {
      return switch (_tab) {
        1 => r.status == ReportStatus.fresh,
        2 => r.status == ReportStatus.reviewing,
        3 => r.status == ReportStatus.resolved,
        _ => true,
      };
    }).toList();

    return _Page(
      title: 'Reports',
      subtitle: 'Safety and moderation',
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Segmented(items: const ['All', 'New', 'Reviewing', 'Resolved'], index: _tab, onChanged: (i) => setState(() => _tab = i)),
        ),
        const SizedBox(height: 16),
        if (list.isEmpty)
          const EmptyState(icon: Icons.flag_outlined, title: 'All clear', body: 'No reports in this state.')
        else
          for (final r in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Surface(
                onTap: () => _detail(context, r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(r.id, style: Ty.mono(size: 11, color: C.text3, ls: 0.4)),
                              const SizedBox(width: 10),
                              _status(_label(r.status)),
                              const Spacer(),
                              Text(r.when, style: Ty.mono(size: 10, color: C.text4, ls: 0.3)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(r.reason, style: Ty.title.copyWith(fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('${r.subject} · reported by ${r.reporter}', style: Ty.small.copyWith(fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: C.text4),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  String _label(ReportStatus s) => switch (s) {
        ReportStatus.fresh => 'New',
        ReportStatus.reviewing => 'Reviewing',
        ReportStatus.resolved => 'Resolved',
      };

  void _detail(BuildContext context, Report r) {
    showSheet(
      context,
      label: r.id,
      title: r.reason,
      builder: (ctx) => SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Group(children: [
              RowTile(title: 'Subject', value: r.subject, chevron: false),
              RowTile(title: 'Reported by', value: r.reporter, chevron: false),
              RowTile(title: 'Received', value: r.when, chevron: false),
              RowTile(title: 'Status', trailing: _status(_label(r.status)), chevron: false),
            ]),
            const SizedBox(height: 14),
            Banner2(
              icon: Icons.lock_outline_rounded,
              color: C.accent,
              text: 'Message content wasn\'t attached. Access requires the reporter\'s consent and a second admin\'s approval.',
              action: 'Request',
              onAction: () {
                Navigator.pop(ctx);
                showToast(context, 'Consent requested from ${r.reporter}', icon: Icons.lock_outline_rounded);
              },
            ),
            const SizedBox(height: 16),
            if (r.status == ReportStatus.fresh)
              Btn('Start review', onTap: () {
                r.status = ReportStatus.reviewing;
                app.update();
                Navigator.pop(ctx);
              }),
            if (r.status == ReportStatus.reviewing) ...[
              Btn('Mark resolved', onTap: () {
                r.status = ReportStatus.resolved;
                app.update();
                Navigator.pop(ctx);
                showToast(context, '${r.id} resolved');
              }),
              const SizedBox(height: 8),
              Btn.secondary('Reassign client', onTap: () {
                Navigator.pop(ctx);
                _pickTherapist(context, r.reporter);
              }),
              const SizedBox(height: 8),
              Btn.destructive('Restrict account', onTap: () async {
                Navigator.pop(ctx);
                final ok = await confirm(
                  context,
                  icon: Icons.gpp_maybe_outlined,
                  title: 'Restrict this account?',
                  body: 'The account involved will be paused from messaging pending review. Both parties are notified neutrally.',
                  confirmLabel: 'Restrict',
                  destructive: true,
                );
                if (ok && context.mounted) showToast(context, 'Account restricted');
              }),
            ],
            if (r.status == ReportStatus.resolved) Text('Resolved — no further action needed.', style: Ty.small),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── Settings ─────────────────────────────

class _Settings extends StatefulWidget {
  const _Settings();

  @override
  State<_Settings> createState() => _SettingsState();
}

class _SettingsState extends State<_Settings> {
  bool _autoAssign = true;
  bool _twoPerson = true;
  double _maxClients = 12;

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Settings',
      subtitle: 'System-wide configuration',
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('Emergency information'),
              Group(children: [
                const RowTile(title: 'Region', value: EmergencyConfig.region, chevron: false),
                const RowTile(title: EmergencyConfig.primaryName, value: EmergencyConfig.primaryNumber, chevron: false),
                for (final (name, number, _) in EmergencyConfig.lines) RowTile(title: name, value: number, chevron: false),
                RowTile(icon: Icons.add_rounded, title: 'Add helpline', onTap: () => showToast(context, 'Helpline editor')),
              ]),
              const SizedBox(height: 24),
              const SectionTitle('Matching'),
              Group(children: [
                RowTile(
                  title: 'Auto-assign new clients',
                  subtitle: 'Match by concerns, language and availability',
                  trailing: Switch(value: _autoAssign, onChanged: (v) => setState(() => _autoAssign = v)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text('Max clients per therapist', style: Ty.bodyStrong.copyWith(fontSize: 14.5))),
                          Text('${_maxClients.round()}', style: Ty.mono(size: 13, color: C.text)),
                        ],
                      ),
                      Slider(
                        value: _maxClients,
                        min: 4,
                        max: 20,
                        divisions: 16,
                        activeColor: C.accent,
                        inactiveColor: C.s3,
                        onChanged: (v) => setState(() => _maxClients = v),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 24),
              const SectionTitle('Privacy & data'),
              Group(children: [
                RowTile(
                  title: 'Two-person approval for safety access',
                  subtitle: 'Required before any admin can view reported content',
                  trailing: Switch(value: _twoPerson, onChanged: (v) => setState(() => _twoPerson = v)),
                ),
                const RowTile(title: 'Closed conversation retention', value: '30 days', chevron: false),
                const RowTile(title: 'Admin audit log', value: 'Enabled', chevron: false),
                const RowTile(title: 'Data region', value: 'ap-south-1', chevron: false),
              ]),
            ],
          ),
        ),
      ],
    );
  }
}
