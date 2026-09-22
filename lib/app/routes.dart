import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:meditrack/features/startup_page.dart';
import 'package:meditrack/features/auth/login/login_page.dart';
import 'package:meditrack/features/auth/signup/signup_page.dart';
import 'package:meditrack/features/create_profile/create_profile_page.dart';
import 'package:meditrack/features/first_page.dart';
import 'package:meditrack/features/home/home.dart';
import 'package:meditrack/features/onboarding.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const StartupPage(),

  '/first': (context) => const FirstPage(),

  '/onboarding': (context) => const OnboardingPage(),

  '/login': (context) => const LoginPage(),

  '/signup': (context) => const SignupPage(),

  '/profileview': (context) => const CreateProfilePage(),

  '/home': (context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return const HomePage();
    }

    return const LoginPage();
  },
};
