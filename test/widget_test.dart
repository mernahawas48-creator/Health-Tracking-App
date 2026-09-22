import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/auth/login/login_page.dart';
import 'package:meditrack/features/auth/signup/signup_page.dart';
import 'package:meditrack/themes/app_theme.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets('Login and Signup render in ${dark ? 'dark' : 'light'} theme', (
      tester,
    ) async {
      for (final page in [const LoginPage(), const SignupPage()]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            home: page,
          ),
        );
        expect(find.byType(TextFormField), findsWidgets);
        expect(tester.takeException(), isNull);
      }
    });
  }
}
