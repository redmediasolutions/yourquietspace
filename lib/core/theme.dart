import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colour tokens. Dark-first, monochrome, one calm accent.
class C {
  static const bg = Color(0xFF0B0B0D);
  static const s1 = Color(0xFF121214); // primary surface
  static const s2 = Color(0xFF18181B); // secondary surface
  static const s3 = Color(0xFF202023); // elevated surface
  static const border = Color(0xFF27272A);
  static const hairline = Color(0xFF1C1C1F);

  static const text = Color(0xFFF5F5F5);
  static const text2 = Color(0xFFA1A1AA);
  static const text3 = Color(0xFF71717A);
  static const text4 = Color(0xFF52525B);

  /// The single accent: a muted, cool blue.
  static const accent = Color(0xFF9DB7F5);
  static Color accentA(double a) => accent.withValues(alpha: a);

  /// Presence only — kept desaturated so it never reads as "success green".
  static const online = Color(0xFF86C9AE);
  static const away = Color(0xFFD4B37A);

  /// Restrained warm treatment for safety / destructive actions.
  static const warm = Color(0xFFE08A76);
  static Color warmA(double a) => warm.withValues(alpha: a);
}

/// Radii — few, deliberate.
class R {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 22.0;
}

/// Typography. Inter for UI, JetBrains Mono sparingly for IDs / status.
class Ty {
  static TextStyle _i(double size, FontWeight w, {double ls = 0, double h = 1.35, Color color = C.text}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, letterSpacing: ls, height: h, color: color);

  static TextStyle get display => _i(34, FontWeight.w500, ls: -1.1, h: 1.12);
  static TextStyle get h1 => _i(26, FontWeight.w500, ls: -0.7, h: 1.18);
  static TextStyle get h2 => _i(20, FontWeight.w500, ls: -0.35, h: 1.25);
  static TextStyle get title => _i(16, FontWeight.w500, ls: -0.15);
  static TextStyle get body => _i(15, FontWeight.w400, h: 1.55, color: C.text2);
  static TextStyle get bodyStrong => _i(15, FontWeight.w400, h: 1.55);
  static TextStyle get small => _i(13, FontWeight.w400, h: 1.45, color: C.text2);
  static TextStyle get tiny => _i(11.5, FontWeight.w400, color: C.text3);
  static TextStyle get button => _i(15, FontWeight.w500, ls: -0.1);

  static TextStyle mono({double size = 10.5, Color color = C.text3, FontWeight w = FontWeight.w500, double ls = 1.3}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: w, letterSpacing: ls, color: color, height: 1.3);
}

/// Subtle fade + rise transition used across the app.
Route<T> fade<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) {
        final curved = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.025), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: C.bg,
    colorScheme: const ColorScheme.dark(
      primary: C.accent,
      onPrimary: C.bg,
      secondary: C.accent,
      surface: C.s1,
      onSurface: C.text,
      error: C.warm,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: C.text, displayColor: C.text),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    splashColor: Colors.transparent,
    hoverColor: Colors.white.withValues(alpha: 0.02),
    dividerColor: C.border,
    dividerTheme: const DividerThemeData(color: C.hairline, thickness: 1, space: 1),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: C.accent,
      selectionColor: C.accentA(0.3),
      selectionHandleColor: C.accent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.s1,
      isDense: true,
      hintStyle: GoogleFonts.inter(color: C.text4, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.sm), borderSide: const BorderSide(color: C.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.sm), borderSide: const BorderSide(color: C.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.sm), borderSide: BorderSide(color: C.accentA(0.7))),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.sm), borderSide: BorderSide(color: C.warmA(0.7))),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.bg : C.text3),
      trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.accent : C.s3),
      trackOutlineColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.accent : C.border),
    ),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent, elevation: 0),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(color: C.s3, borderRadius: BorderRadius.circular(R.xs), border: Border.all(color: C.border)),
      textStyle: GoogleFonts.inter(fontSize: 12, color: C.text),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(C.border),
      radius: const Radius.circular(8),
      thickness: WidgetStateProperty.all(4),
    ),
  );
}
