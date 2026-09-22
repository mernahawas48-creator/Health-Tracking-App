import 'package:meditrack/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final headerHeight = (MediaQuery.sizeOf(context).height * .28).clamp(
      130.0,
      240.0,
    );
    return Scaffold(
      backgroundColor: Appcolors.Primary,
      body: Column(
        children: [
          // top: size.height*0.1,
          // left: size.width*0.3,
          Image.asset(
            'assets/images/auth.png',
            width: double.infinity,
            height: headerHeight,
            fit: BoxFit.contain,
          ),

          // Positioned(
          //   top: size.height*0.17,
          //   left: size.width*0.02,
          //   child: Image.asset(
          //     'assets/images/get_started2.png'
          //   )
          //   ),
          // Positioned(
          //   top: size.height*0.1,
          //   left: size.width*0.1,
          //   child: Text(
          //     '“Right Dose \nAlways”',
          //     style: TextStyle(
          //       fontStyle: FontStyle.italic,
          //       fontSize: 30,
          //       fontWeight: FontWeight.bold,
          //       color: context.appSurface
          //     ),
          // )
          // ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                color: context.appSurface,
              ),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
