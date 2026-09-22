import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;

  const AuthLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Appcolors.Primary,

      body: Column(
        children: [
          Image.asset(
            'assets/images/auth.png',
            width: size.width,
            height: size.height * 0.3,
            fit: BoxFit.contain,
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: Appcolors.White,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}