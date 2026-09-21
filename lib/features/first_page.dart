import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/l10n/app_strings.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      backgroundColor: Appcolors.White,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/first_time_question.png',
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.05,),
            Text(
              strings.text('firstTimeQuestion'),
              style: const TextStyle(
                color: Appcolors.Black2,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: MediaQuery.sizeOf(context).height * 0.05,),
            
            SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Appcolors.Primary,
                elevation: 5,
                
               shape:  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
               )
              ),
              onPressed: (){
                Navigator.pushNamed(context, '/onboarding');
              }, 
              child: Text(
                strings.text('yes'),
                style: TextStyle(
                  color: Appcolors.White,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              )
              ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.04,),
              
              SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Appcolors.Primary,
                elevation: 5,
                
               shape:  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
               )
              ),
              onPressed: (){
                Navigator.pushNamed(context, '/login');

              }, 
              child: Text(
                strings.text('no'),
                style: TextStyle(
                  color: Appcolors.White,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              )
              ),
              )
              
              ],
            )
          
        ),

    );
  }
}
