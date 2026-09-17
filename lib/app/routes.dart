import 'package:flutter/material.dart';
import 'package:meditrack/features/onboarding.dart';
import 'package:meditrack/features/login.dart';
import 'package:meditrack/features/signup.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/' : (context) => const OnboardingPage(),
  '/login': (context) => const LoginPage(),
  '/signup': (context) => const SignupPage(),

};