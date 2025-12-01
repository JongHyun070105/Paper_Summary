import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '북마크',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.bookmark,
                        size: 60,
                        color: Colors.grey[800],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '저장된 논문이 없습니다.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
