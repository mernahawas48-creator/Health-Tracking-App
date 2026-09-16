import 'package:flutter/material.dart';
import 'package:meditrack/features/onboarding.dart';
import 'package:meditrack/features/login.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/' : (context) => const OnboardingPage(),
  '/login': (context) => const LoginPage(),

};