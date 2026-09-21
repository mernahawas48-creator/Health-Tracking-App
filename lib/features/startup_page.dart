import 'package:flutter/material.dart';
import 'package:meditrack/services/local_session_service.dart';

class StartupPage extends StatelessWidget { const StartupPage({super.key});
  @override Widget build(BuildContext context) => FutureBuilder<List<bool>>(
    future: Future.wait([LocalSessionService.onboardingComplete(), LocalSessionService.signedIn()]),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      final route = snapshot.data![1] ? '/home' : snapshot.data![0] ? '/login' : '/onboarding';
      WidgetsBinding.instance.addPostFrameCallback((_) => Navigator.pushReplacementNamed(context, route));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    },
  );
}
