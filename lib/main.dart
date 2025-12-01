import 'package:flutter/material.dart';
import 'package:flutter_paper_summary/screens/onboarding_screen.dart';
import 'package:flutter_paper_summary/screens/login_screen.dart';
import 'package:flutter_paper_summary/screens/main_screen.dart';
import 'package:flutter_paper_summary/screens/interest_selection_screen.dart';
import 'package:flutter_paper_summary/screens/paper_detail_screen.dart';
import 'package:flutter_paper_summary/theme/app_theme.dart';

void main() {
  runApp(const PaperReaderApp());
}

class PaperReaderApp extends StatelessWidget {
  const PaperReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paper Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/onboarding',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/interest': (context) => const InterestSelectionScreen(),
        '/main': (context) => const MainScreen(),
        '/paper': (context) => const PaperDetailScreen(),
      },
    );
  }
}
