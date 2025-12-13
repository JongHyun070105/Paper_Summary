import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_paper_summary/services/auth_service.dart';
import 'package:flutter_paper_summary/screens/onboarding_screen.dart';
import 'package:flutter_paper_summary/screens/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F0F12),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)),
            ),
          );
        }

        // 로그인된 사용자가 있는 경우
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }

        // 로그인되지 않은 경우
        return const OnboardingScreen();
      },
    );
  }
}
