import 'package:flutter/material.dart';
import 'package:meditrack/themes/app_theme.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/first');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appCanvas,
      body: Center(
        child: SizedBox(
          width: 108,
          height: 108,
          child: Center(
            child: Image.asset(
              'assets/images/logo1.png',
              width: 37,
              height: 64,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
