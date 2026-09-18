import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/features/login.dart';
import 'package:meditrack/features/onboarding.dart';

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Is this your ',
                    style: TextStyle(
                      color: Appcolors.Black2,
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  TextSpan(
                    text: 'first time ?',
                    style: TextStyle(
                      color: Appcolors.Primary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold
                    )
                  ),
                ]
              )
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
                'Yes',
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
                'No',
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