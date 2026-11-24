import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'theme.dart';

// ───────────────────────────── Press feedback ─────────────────────────────

/// Gentle scale-down on press. Used by every tappable surface.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const Pressable({super.key, required this.child, this.onTap, this.scale = 0.985});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null) return;
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _down ? 0.85 : 1,
          duration: const Duration(milliseconds: 120),
          child: widget.child,
        ),
      ),
    );
  }
}

// ───────────────────────────── Buttons ─────────────────────────────

enum BtnKind { primary, secondary, ghost, destructive, accent }

class Btn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final BtnKind kind;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final double height;

  const Btn(
    this.label, {
    super.key,
    this.onTap,
    this.kind = BtnKind.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.height = 52,
  });

  const Btn.secondary(this.label, {super.key, this.onTap, this.icon, this.loading = false, this.expand = true, this.height = 52})
      : kind = BtnKind.secondary;

  const Btn.ghost(this.label, {super.key, this.onTap, this.icon, this.loading = false, this.expand = true, this.height = 48})
      : kind = BtnKind.ghost;

  const Btn.destructive(this.label, {super.key, this.onTap, this.icon, this.loading = false, this.expand = true, this.height = 52})
      : kind = BtnKind.destructive;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    final (bg, fg, border) = switch (kind) {
      BtnKind.primary => (C.text, C.bg, Colors.transparent),
      BtnKind.accent => (C.accent, C.bg, Colors.transparent),
      BtnKind.secondary => (C.s2, C.text, C.border),
      BtnKind.ghost => (Colors.transparent, C.text2, Colors.transparent),
      BtnKind.destructive => (C.warmA(0.1), C.warm, C.warmA(0.28)),
    };

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.6, color: fg))
        else ...[
          if (icon != null) ...[Icon(icon, size: 18, color: fg), const SizedBox(width: 8)],
          Text(label, style: Ty.button.copyWith(color: fg)),
        ],
      ],
    );

    return Pressable(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled || loading ? 1 : 0.38,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: expand ? 20 : 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(R.sm + 2),
            border: Border.all(color: border),
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Round outline icon button (back, menu, etc.).
class IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool dot;
  final String? tooltip;

  const IconBtn(this.icon, {super.key, this.onTap, this.size = 40, this.dot = false, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final btn = Pressable(
      onTap: onTap,
      scale: 0.94,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: C.s1,
          shape: BoxShape.circle,
          border: Border.all(color: C.border),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: size * 0.45, color: C.text),
            if (dot)
              Positioned(
                top: size * 0.24,
                right: size * 0.26,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: C.accent, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

class TextLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double size;

  const TextLink(this.label, {super.key, this.onTap, this.color = C.accent, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(label, style: Ty.small.copyWith(color: color, fontSize: size, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ───────────────────────────── Surfaces ─────────────────────────────

class Surface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color color;
  final Color borderColor;
  final double radius;

  const Surface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color = C.s1,
    this.borderColor = C.border,
    this.radius = R.md,
  });

  @override
  Widget build(BuildContext context) {
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
    return onTap == null ? box : Pressable(onTap: onTap, child: box);
  }
}

/// Small uppercase technical label — the Nothing-ish metadata voice.
class Label extends StatelessWidget {
  final String text;
  final Color color;
  final double size;

  const Label(this.text, {super.key, this.color = C.text3, this.size = 10.5});

  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(), style: Ty.mono(size: size, color: color));
}

/// Section heading with optional trailing action.
class SectionTitle extends StatelessWidget {
  final String label;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle(this.label, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Label(label)),
          if (action != null) TextLink(action!, onTap: onAction, size: 13),
        ],
      ),
    );
  }
}

/// List row inside a grouped Surface.
class RowTile extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;
  final bool chevron;

  const RowTile({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.chevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.995,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19, color: titleColor ?? C.text2),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Ty.bodyStrong.copyWith(fontSize: 14.5, color: titleColor ?? C.text, height: 1.3)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: Ty.tiny.copyWith(fontSize: 12.5, height: 1.4)),
                  ],
                ],
              ),
            ),
            if (value != null) Text(value!, style: Ty.small.copyWith(color: C.text3)),
            if (trailing != null) trailing!,
            if (chevron && trailing == null && onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, size: 18, color: C.text4),
            ],
          ],
        ),
      ),
    );
  }
}

/// A Surface that stacks RowTiles with hairline separators.
class Group extends StatelessWidget {
  final List<Widget> children;

  const Group({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: C.s1,
        borderRadius: BorderRadius.circular(R.md),
        border: Border.all(color: C.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const Divider(indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

// ───────────────────────────── Status ─────────────────────────────

enum Presence { online, away, offline }

extension PresenceX on Presence {
  String get label => switch (this) {
        Presence.online => 'Online',
        Presence.away => 'Away',
        Presence.offline => 'Offline',
      };

  Color get color => switch (this) {
        Presence.online => C.online,
        Presence.away => C.away,
        Presence.offline => C.text4,
      };
}

/// Presence dot with a slow, quiet pulse when online.
class StatusDot extends StatefulWidget {
  final Presence presence;
  final double size;

  const StatusDot(this.presence, {super.key, this.size = 7});

  @override
  State<StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<StatusDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

  @override
  void initState() {
    super.initState();
    if (widget.presence == Presence.online) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant StatusDot old) {
    super.didUpdateWidget(old);
    if (widget.presence == Presence.online && !_c.isAnimating) {
      _c.repeat();
    } else if (widget.presence != Presence.online) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final color = widget.presence.color;
    return SizedBox(
      width: s * 2.4,
      height: s * 2.4,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            if (widget.presence == Presence.online)
              Container(
                width: s + s * 1.4 * _c.value,
                height: s + s * 1.4 * _c.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.35 * (1 - _c.value)),
                ),
              ),
            Container(width: s, height: s, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}

/// Compact pill: "● ONLINE", "PRIVATE", "VERIFIED", "UNREAD".
class Tag extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final Presence? presence;
  final bool filled;

  const Tag(this.text, {super.key, this.color = C.text2, this.icon, this.presence, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(presence != null ? 4 : 8, 4, 9, 4),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: filled ? color.withValues(alpha: 0.22) : C.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (presence != null) StatusDot(presence!, size: 6),
          if (icon != null) ...[Icon(icon, size: 11, color: color), const SizedBox(width: 5)],
          Text(text.toUpperCase(), style: Ty.mono(size: 9.5, color: color, ls: 1.1)),
        ],
      ),
    );
  }
}

class PrivacyTag extends StatelessWidget {
  final String text;

  const PrivacyTag({super.key, this.text = 'Private'});

  @override
  Widget build(BuildContext context) => Tag(text, icon: Icons.lock_outline_rounded, color: C.accent, filled: true);
}

// ───────────────────────────── Avatars ─────────────────────────────

/// Monogram avatar — no photography, just a quiet mark.
class Monogram extends StatelessWidget {
  final String text;
  final double size;
  final Presence? presence;
  final bool accent;

  const Monogram(this.text, {super.key, this.size = 44, this.presence, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final letters = text.trim().isEmpty ? '?' : text.trim().substring(0, math.min(2, text.trim().length)).toUpperCase();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent ? C.accentA(0.1) : C.s3,
              border: Border.all(color: accent ? C.accentA(0.35) : C.border),
            ),
            child: Center(
              child: Text(
                letters,
                style: Ty.mono(size: size * 0.3, color: accent ? C.accent : C.text, ls: 0.5, w: FontWeight.w500),
              ),
            ),
          ),
          if (presence != null)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  color: presence!.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: C.bg, width: 2.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────────── Navigation ─────────────────────────────

class TopBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget> actions;
  final bool back;
  final VoidCallback? onBack;
  final IconData backIcon;

  const TopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions = const [],
    this.back = true,
    this.onBack,
    this.backIcon = Icons.chevron_left_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            if (back)
              IconBtn(backIcon, onTap: onBack ?? () => Navigator.of(context).maybePop())
            else
              const SizedBox(width: 40),
            Expanded(
              child: Center(
                child: titleWidget ?? (title == null ? const SizedBox() : Text(title!, style: Ty.title)),
              ),
            ),
            if (actions.isEmpty)
              const SizedBox(width: 40)
            else
              Row(mainAxisSize: MainAxisSize.min, children: actions),
          ],
        ),
      ),
    );
  }
}

/// Animated segmented control (tabs, ranges, presence).
class Segmented extends StatelessWidget {
  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;
  final double height;

  const Segmented({super.key, required this.items, required this.index, required this.onChanged, this.height = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: C.s1,
        borderRadius: BorderRadius.circular(R.sm),
        border: Border.all(color: C.border),
      ),
      child: LayoutBuilder(
        builder: (_, box) {
          final w = box.maxWidth / items.length;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: w * index,
                top: 0,
                bottom: 0,
                width: w,
                child: Container(
                  decoration: BoxDecoration(
                    color: C.s3,
                    borderRadius: BorderRadius.circular(R.sm - 3),
                    border: Border.all(color: C.border),
                  ),
                ),
              ),
              Row(
                children: List.generate(items.length, (i) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: Ty.small.copyWith(
                            color: i == index ? C.text : C.text3,
                            fontWeight: FontWeight.w500,
                          ),
                          child: Text(items[i]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ───────────────────────────── Inputs ─────────────────────────────

class Field extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool password;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final IconData? prefix;
  final Widget? suffix;
  final String? helper;
  final String? error;
  final TextInputType? keyboard;
  final bool mono;

  const Field({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.password = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.prefix,
    this.suffix,
    this.helper,
    this.error,
    this.keyboard,
    this.mono = false,
  });

  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[Label(widget.label!), const SizedBox(height: 8)],
        TextField(
          controller: widget.controller,
          obscureText: widget.password && _obscure,
          maxLines: widget.password ? 1 : widget.maxLines,
          minLines: widget.maxLines > 1 ? widget.maxLines : null,
          maxLength: widget.maxLength,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboard,
          style: widget.mono ? Ty.mono(size: 15, color: C.text, ls: 0.4) : Ty.bodyStrong,
          decoration: InputDecoration(
            hintText: widget.hint,
            counterText: '',
            prefixIcon: widget.prefix == null ? null : Icon(widget.prefix, size: 18, color: C.text3),
            suffixIcon: widget.password
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: C.text3),
                  )
                : widget.suffix,
            errorText: null,
            enabledBorder: widget.error == null
                ? null
                : OutlineInputBorder(borderRadius: BorderRadius.circular(R.sm), borderSide: BorderSide(color: C.warmA(0.6))),
          ),
        ),
        if (widget.error != null || widget.helper != null) ...[
          const SizedBox(height: 8),
          Text(widget.error ?? widget.helper!, style: Ty.tiny.copyWith(color: widget.error != null ? C.warm : C.text3)),
        ],
      ],
    );
  }
}

/// Selectable chip used in onboarding and filters.
class ChoiceChipX extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ChoiceChipX({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? C.accentA(0.1) : C.s1,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? C.accentA(0.55) : C.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: selected
                  ? const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.check_rounded, size: 15, color: C.accent),
                    )
                  : const SizedBox.shrink(),
            ),
            Text(label, style: Ty.small.copyWith(color: selected ? C.text : C.text2, fontWeight: FontWeight.w500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────── Decorative ─────────────────────────────

/// Fine dot grid that fades out radially. Used sparingly.
class DotGrid extends StatelessWidget {
  final double spacing;
  final double opacity;
  final Alignment focus;

  const DotGrid({super.key, this.spacing = 18, this.opacity = 0.09, this.focus = Alignment.topCenter});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => RadialGradient(
          center: focus,
          radius: 1.0,
          colors: [Colors.white, Colors.white.withValues(alpha: 0)],
        ).createShader(rect),
        child: CustomPaint(painter: _DotPainter(spacing, opacity), size: Size.infinite),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  final double spacing;
  final double opacity;

  _DotPainter(this.spacing, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withValues(alpha: opacity);
    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPainter old) => old.spacing != spacing || old.opacity != opacity;
}

/// Quiet accent glow, used behind key moments only.
class Glow extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;

  const Glow({super.key, this.size = 320, this.opacity = 0.10, this.color = C.accent});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color.withValues(alpha: opacity), color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

// ───────────────────────────── States ─────────────────────────────

class Skeleton extends StatefulWidget {
  final double height;
  final double? width;
  final double radius;

  const Skeleton({super.key, this.height = 14, this.width, this.radius = 6});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(-1.5 + _c.value * 3, 0),
            end: Alignment(-0.5 + _c.value * 3, 0),
            colors: const [C.s2, C.s3, C.s2],
          ),
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;
  final String? code;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
    this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(child: ClipOval(child: DotGrid(spacing: 10, opacity: 0.18, focus: Alignment.center))),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: C.bg, shape: BoxShape.circle, border: Border.all(color: C.border)),
                  child: Icon(icon, size: 22, color: C.text2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (code != null) ...[Label(code!), const SizedBox(height: 8)],
          Text(title, textAlign: TextAlign.center, style: Ty.h2.copyWith(fontSize: 18)),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center, style: Ty.small),
          if (action != null) ...[
            const SizedBox(height: 22),
            Btn.secondary(action!, onTap: onAction, expand: false, height: 44),
          ],
        ],
      ),
    );
  }
}

/// Thin inline banner — offline, reconnecting, therapist away, etc.
class Banner2 extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final String? action;
  final VoidCallback? onAction;
  final bool spinner;

  const Banner2({
    super.key,
    required this.icon,
    required this.text,
    this.color = C.text2,
    this.action,
    this.onAction,
    this.spinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(R.sm),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          if (spinner)
            SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 1.4, color: color))
          else
            Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Ty.small.copyWith(color: color, fontSize: 13))),
          if (action != null) TextLink(action!, onTap: onAction, color: C.text, size: 13),
        ],
      ),
    );
  }
}

// ───────────────────────────── Feedback ─────────────────────────────

void showToast(BuildContext context, String message, {IconData icon = Icons.check_rounded}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;
  var removed = false;
  entry = OverlayEntry(
    builder: (_) => _Toast(
      message: message,
      icon: icon,
      onDone: () {
        if (!removed) {
          removed = true;
          entry.remove();
        }
      },
    ),
  );
  overlay.insert(entry);
}

class _Toast extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onDone;

  const _Toast({required this.message, required this.icon, required this.onDone});

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await _c.forward();
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    await _c.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.paddingOf(context).bottom + 96,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(curved),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                  decoration: BoxDecoration(
                    color: C.s3,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: C.border),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, size: 16, color: C.accent),
                      const SizedBox(width: 8),
                      Text(widget.message, style: Ty.small.copyWith(color: C.text, fontSize: 13.5)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with consistent chrome.
Future<T?> showSheet<T>(BuildContext context, {String? title, String? label, required Widget Function(BuildContext) builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: Container(
        margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        decoration: BoxDecoration(
          color: C.s1,
          borderRadius: BorderRadius.circular(R.lg + 4),
          border: Border.all(color: C.border),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: C.border, borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(height: 18),
                if (label != null) ...[Label(label), const SizedBox(height: 6)],
                if (title != null) ...[Text(title, style: Ty.h2), const SizedBox(height: 14)],
                Flexible(child: builder(ctx)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// Modal confirmation. Explains consequences before anything destructive happens.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
  IconData? icon,
}) async {
  final r = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.65),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (ctx, _, __) => Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: C.s1,
                borderRadius: BorderRadius.circular(R.lg),
                border: Border.all(color: C.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: destructive ? C.warmA(0.1) : C.s3,
                        shape: BoxShape.circle,
                        border: Border.all(color: destructive ? C.warmA(0.3) : C.border),
                      ),
                      child: Icon(icon, size: 18, color: destructive ? C.warm : C.text),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(title, style: Ty.h2.copyWith(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(body, style: Ty.small.copyWith(fontSize: 14)),
                  const SizedBox(height: 22),
                  destructive
                      ? Btn.destructive(confirmLabel, onTap: () => Navigator.pop(ctx, true), height: 48)
                      : Btn(confirmLabel, onTap: () => Navigator.pop(ctx, true), height: 48),
                  const SizedBox(height: 6),
                  Btn.ghost(cancelLabel, onTap: () => Navigator.pop(ctx, false), height: 44),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (_, a, __, child) => FadeTransition(
      opacity: a,
      child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child),
    ),
  );
  return r ?? false;
}

/// Responsive width cap so phone layouts stay readable on tablets.
class Narrow extends StatelessWidget {
  final Widget child;
  final double max;

  const Narrow({super.key, required this.child, this.max = 560});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: max), child: child),
    );
  }
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 5) return 'Good night.';
  if (h < 12) return 'Good morning.';
  if (h < 17) return 'Good afternoon.';
  return 'Good evening.';
}

const _wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String fmtTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'AM' : 'PM'}';
}

String fmtDate(DateTime d) => '${_wd[d.weekday - 1]}, ${d.day} ${_mo[d.month - 1]}';
String fmtDay(DateTime d) => _wd[d.weekday - 1];

String fmtRelativeDay(DateTime d) {
  final now = DateTime.now();
  final a = DateTime(now.year, now.month, now.day);
  final b = DateTime(d.year, d.month, d.day);
  final diff = a.difference(b).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return fmtDate(d);
}
