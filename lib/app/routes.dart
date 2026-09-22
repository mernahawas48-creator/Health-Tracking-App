import 'package:flutter/material.dart';
import 'package:meditrack/features/startup_page.dart';
import 'package:meditrack/features/auth/login/login_page.dart';
import 'package:meditrack/features/auth/signup/signup_page.dart';
import 'package:meditrack/features/create_profile/create_profile_page.dart';
import 'package:meditrack/features/first_page.dart';
import 'package:meditrack/features/home/home.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/features/auth/session_cubit.dart';
import 'package:meditrack/features/onboarding.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const StartupPage(),
  '/onboarding': (context) => const OnboardingPage(),
  '/login': (context) => const LoginPage(),
  '/signup': (context) => const SignupPage(),
  '/home': (context) =>
      context.read<SessionCubit>().state == SessionStatus.signedIn
      ? const HomePage()
      : const StartupPage(),
  '/profileview': (context) => const CreateProfilePage(),
};
