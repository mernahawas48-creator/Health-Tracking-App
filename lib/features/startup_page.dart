import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meditrack/features/auth/session_cubit.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<SessionCubit, SessionStatus>(
    builder: (context, status) {
      final route = switch (status) {
        SessionStatus.signedIn => '/home',
        SessionStatus.signedOut => '/login',
        SessionStatus.onboarding => '/onboarding',
        _ => null,
      };
      if (route != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted && ModalRoute.of(context)?.isCurrent == true) {
            Navigator.pushReplacementNamed(context, route);
          }
        });
      }
      if (status == SessionStatus.failure) {
        return Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => context.read<SessionCubit>().restore(),
              child: const Text('Retry'),
            ),
          ),
        );
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    },
  );
}
