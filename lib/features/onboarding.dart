import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget{
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Image.asset(
              "assets/images/onboarding.png",
              width: double.infinity,
              fit: BoxFit.fitWidth,
              ),
              const SizedBox(height: 50,),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "Never miss",
                      style: TextStyle(
                        color: Color(0xff00a1a9),
                        fontSize: 40,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    TextSpan(
                      text: " your\nmedicines again",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ]
                ),
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: 10,),
            Text(
              "With gentle reminders delivered at just\nthe right time, you'll always know when\nto take your medicines and keep your\nhealth on track.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:18,
                fontWeight: FontWeight.normal,
              )
            ),
            const Spacer(),
            Padding(padding: const EdgeInsets.only(
              bottom: 40,
              left: 50,
              right: 50
            ),
            child: SizedBox(
              width: double.infinity,
              child:ElevatedButton(
              onPressed: (){

              }, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff00a1a9),
                foregroundColor: Color(0xffE6E6E6),
                elevation: 5,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(15)
                )

                
              )
              ,
              child:
              Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffE6E6E6),

                ),
              )
              ) ,
            ),
            ),
            
          ],
        )
        ),
    );  
    }
}