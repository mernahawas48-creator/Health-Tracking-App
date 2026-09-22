import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';

class ProfileStepLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String subtitle;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  const ProfileStepLayout({
    super.key, 
    required this.child, 
    required this.title, 
    required this.subtitle, 
    required this.currentStep, 
    required this.totalSteps, 
    required this.onNext
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title
            ),
            Text(
              subtitle
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
            Expanded(
              child: child
              ),
              ElevatedButton(
                onPressed: onNext, 
                child: const Text('Next'))
          ],
        )
          ),
          
        ),
    );
  }
}