// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_paper_summary/main.dart';
import 'package:flutter_paper_summary/services/theme_service.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    // Create a theme service for testing
    final themeService = ThemeService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(PaperReaderApp(themeService: themeService));

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
