import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_paper_summary/screens/onboarding_screen.dart';
import 'package:flutter_paper_summary/screens/login_screen.dart';
import 'package:flutter_paper_summary/screens/main_screen.dart';
import 'package:flutter_paper_summary/screens/interest_selection_screen.dart';
import 'package:flutter_paper_summary/screens/paper_detail_screen.dart';
import 'package:flutter_paper_summary/screens/settings_screen.dart';
import 'package:flutter_paper_summary/screens/upload_screen.dart';
import 'package:flutter_paper_summary/screens/my_papers_screen.dart';
import 'package:flutter_paper_summary/theme/app_theme.dart';
import 'package:flutter_paper_summary/screens/auth_wrapper.dart';
import 'package:flutter_paper_summary/services/theme_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final themeService = ThemeService();
  await themeService.loadTheme();

  runApp(PaperReaderApp(themeService: themeService));
}

class PaperReaderApp extends StatelessWidget {
  final ThemeService themeService;

  const PaperReaderApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Paper Reader',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            home: const AuthWrapper(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/interest': (context) => const InterestSelectionScreen(),
              '/main': (context) => const MainScreen(),
              '/paper': (context) => const PaperDetailScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/upload': (context) => const UploadScreen(),
              '/my-papers': (context) => const MyPapersScreen(),
            },
          );
        },
      ),
    );
  }
}
