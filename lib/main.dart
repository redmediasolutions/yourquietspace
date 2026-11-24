import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'client/onboarding.dart';
import 'core/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: C.bg,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const TherapistApp());
}

class TherapistApp extends StatelessWidget {
  const TherapistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Therapist App',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const SplashScreen(),
    );
  }
}
