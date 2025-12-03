import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Text(
                '환영합니다',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 42,
                  height: 1.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Paper Reader와 함께\n스마트한 논문 읽기를 시작하세요.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[400],
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              _buildSocialButton(
                context,
                'Google로 계속하기',
                LucideIcons.chrome,
                Colors.white,
                Colors.black,
              ),
              const SizedBox(height: 40),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context,
    String text,
    IconData icon,
    Color bgColor,
    Color textColor, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap:
          onTap ?? () => Navigator.pushReplacementNamed(context, '/interest'),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
