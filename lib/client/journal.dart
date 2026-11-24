import 'package:flutter/material.dart';

import '../core/state.dart';
import '../core/theme.dart';
import '../core/widgets.dart';

int _words(String s) => s.trim().isEmpty ? 0 : s.trim().split(RegExp(r'\s+')).length;

// ───────────────────────────── 16. Journal home ─────────────────────────────

class JournalHomeScreen extends StatelessWidget {
  const JournalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final entries = app.journal;
        return SafeArea(
          child: Narrow(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Journal', style: Ty.h1)),
                    if (entries.isNotEmpty)
                      Btn(
                        'Write',
                        icon: Icons.edit_outlined,
                        expand: false,
                        height: 40,
                        kind: BtnKind.secondary,
                        onTap: () => Navigator.of(context).push(fade(const JournalEditorScreen())),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 12, color: C.text3),
                    const SizedBox(width: 6),
                    Text('Only you can read your journal — not your therapist.', style: Ty.tiny),
                  ],
                ),
                const SizedBox(height: 24),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: EmptyState(
                      icon: Icons.edit_outlined,
                      title: 'Some thoughts are easier to understand when you put them somewhere.',
                      body: 'Write a line or a page. No one else will see it.',
                      action: 'Write something',
                      onAction: () => Navigator.of(context).push(fade(const JournalEditorScreen())),
                    ),
                  )
                else ...[
                  Label('${entries.length} entries'),
                  const SizedBox(height: 12),
                  for (final e in entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _EntryCard(entry: e),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  final JournalEntry entry;

  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final hasTitle = e.title.trim().isNotEmpty;
    return Surface(
      onTap: () => Navigator.of(context).push(fade(JournalDetailScreen(id: e.id))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${fmtRelativeDay(e.created).toUpperCase()} · ${fmtTime(e.created)}', style: Ty.mono(size: 9.5, color: C.text3)),
              const Spacer(),
              Text('${_words(e.body)} words', style: Ty.mono(size: 9.5, color: C.text4, ls: 0.4)),
            ],
          ),
          const SizedBox(height: 12),
          Text(hasTitle ? e.title : 'Untitled', style: Ty.title.copyWith(color: hasTitle ? C.text : C.text3)),
          const SizedBox(height: 6),
          Text(e.body, maxLines: 3, overflow: TextOverflow.ellipsis, style: Ty.small.copyWith(height: 1.55)),
        ],
      ),
    );
  }
}

// ───────────────────────────── 17. Editor ─────────────────────────────

class JournalEditorScreen extends StatefulWidget {
  final String? id;

  const JournalEditorScreen({super.key, this.id});

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  late final JournalEntry? _existing = widget.id == null ? null : app.journal.firstWhere((j) => j.id == widget.id);
  late final _title = TextEditingController(text: _existing?.title ?? '');
  late final _body = TextEditingController(text: _existing?.body ?? '');
  late final DateTime _when = _existing?.created ?? DateTime.now();

  bool get _dirty => _title.text != (_existing?.title ?? '') || _body.text != (_existing?.body ?? '');

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _discard() async {
    if (!_dirty) {
      Navigator.of(context).pop();
      return;
    }
    final ok = await confirm(
      context,
      title: 'Discard this entry?',
      body: _existing == null ? 'What you\'ve written will not be saved.' : 'Your changes will be lost. The original entry stays as it was.',
      confirmLabel: 'Discard',
      cancelLabel: 'Keep writing',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (ok && mounted) Navigator.of(context).pop();
  }

  void _save() {
    app.saveJournal(id: widget.id, title: _title.text.trim(), body: _body.text.trim());
    showToast(context, 'Saved to your journal');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _body.text.trim().isNotEmpty && _dirty;
    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _discard();
      },
      child: Scaffold(
        body: SafeArea(
          child: Narrow(
            max: 680,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      TextLink('Discard', color: C.text3, onTap: _discard),
                      Expanded(child: Center(child: Label('${fmtDate(_when)} · ${fmtTime(_when)}'))),
                      Btn('Save', expand: false, height: 36, kind: BtnKind.primary, onTap: canSave ? _save : null),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    children: [
                      TextField(
                        controller: _title,
                        onChanged: (_) => setState(() {}),
                        style: Ty.h1.copyWith(fontSize: 24),
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Title (optional)',
                          hintStyle: Ty.h1.copyWith(fontSize: 24, color: C.text4),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _body,
                        autofocus: _existing == null,
                        onChanged: (_) => setState(() {}),
                        maxLines: null,
                        minLines: 14,
                        textCapitalization: TextCapitalization.sentences,
                        style: Ty.bodyStrong.copyWith(fontSize: 16.5, height: 1.75),
                        decoration: InputDecoration(
                          hintText: 'What\'s on your mind?',
                          hintStyle: Ty.bodyStrong.copyWith(fontSize: 16.5, color: C.text4),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.hairline))),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded, size: 11, color: C.text4),
                      const SizedBox(width: 6),
                      Text('PRIVATE TO YOU', style: Ty.mono(size: 9, color: C.text4)),
                      const Spacer(),
                      Text('${_words(_body.text)} words', style: Ty.mono(size: 9, color: C.text4, ls: 0.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────────── 18. Entry detail ─────────────────────────────

class JournalDetailScreen extends StatelessWidget {
  final String id;

  const JournalDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final idx = app.journal.indexWhere((j) => j.id == id);
        if (idx < 0) return const Scaffold(body: SizedBox());
        final e = app.journal[idx];
        final words = _words(e.body);
        return Scaffold(
          body: SafeArea(
            child: Narrow(
              max: 680,
              child: Column(
                children: [
                  TopBar(actions: [
                    IconBtn(Icons.edit_outlined, tooltip: 'Edit', onTap: () => Navigator.of(context).push(fade(JournalEditorScreen(id: e.id)))),
                  ]),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
                      children: [
                        Label('${fmtDate(e.created)} · ${fmtTime(e.created)}'),
                        const SizedBox(height: 14),
                        Text(e.title.isEmpty ? 'Untitled' : e.title, style: Ty.h1.copyWith(color: e.title.isEmpty ? C.text3 : C.text)),
                        const SizedBox(height: 10),
                        Text('$words words · ${(words / 200).ceil()} min read', style: Ty.tiny),
                        const SizedBox(height: 26),
                        Container(width: 24, height: 1, color: C.border),
                        const SizedBox(height: 26),
                        SelectableText(e.body, style: Ty.bodyStrong.copyWith(fontSize: 16.5, height: 1.8, color: const Color(0xFFE4E4E7))),
                        if (e.edited.difference(e.created).inMinutes > 0) ...[
                          const SizedBox(height: 28),
                          Text('Edited ${fmtRelativeDay(e.edited)} · ${fmtTime(e.edited)}', style: Ty.tiny.copyWith(color: C.text4)),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Btn.secondary('Edit', icon: Icons.edit_outlined, onTap: () => Navigator.of(context).push(fade(JournalEditorScreen(id: e.id)))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Btn.destructive(
                            'Delete',
                            icon: Icons.delete_outline_rounded,
                            onTap: () async {
                              final ok = await confirm(
                                context,
                                icon: Icons.delete_outline_rounded,
                                title: 'Delete this entry?',
                                body: 'It will be permanently removed from this device and our servers. This can\'t be undone.',
                                confirmLabel: 'Delete entry',
                                destructive: true,
                              );
                              if (!ok || !context.mounted) return;
                              showToast(context, 'Entry deleted', icon: Icons.delete_outline_rounded);
                              Navigator.of(context).pop();
                              app.deleteJournal(e.id);
                            },
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
      },
    );
  }
}
