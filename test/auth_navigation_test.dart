import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/features/auth/login/login_page.dart';
import 'package:meditrack/features/auth/signup/signup_page.dart';

void main() {
  testWidgets('Signup has Google option and links to Login', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const SignupPage(),
        routes: {'/login': (_) => const Scaffold(body: Text('LOGIN ROUTE'))},
      ),
    );
    expect(find.text('or continue with'), findsOneWidget);
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('LOGIN ROUTE'), findsOneWidget);
  });

  testWidgets('Login links to the existing Signup route', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginPage(),
        routes: {'/signup': (_) => const Scaffold(body: Text('SIGNUP ROUTE'))},
      ),
    );
    await tester.ensureVisible(find.text('Sign up'));
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();
    expect(find.text('SIGNUP ROUTE'), findsOneWidget);
  });
}
