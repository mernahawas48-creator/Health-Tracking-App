import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';

class OnboardingView extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingView({
    super.key, 
    required this.image, 
    required this.title, 
    required this.description,
    });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      
      children: [
        
        Image.asset(
          image,
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
        
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.01,),
        
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Appcolors.Primary
          ),
        ),
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
        
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal
          ),
        ),
      ],
    );
  }
}