import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/features/onboarding_view.dart';
import 'package:meditrack/features/signup.dart';

class OnboardingPage extends StatefulWidget {
  
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController pageController = PageController();
  int currentPage = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Appcolors.White,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (index){
                setState(() {
                  currentPage = index;
                });
              },
                children: [
                  OnboardingView(
                    image: 'assets/images/onboarding1.png', 
                    title: 'Never miss your medicines again', 
                    description: 'With gentle reminders delivered at just the right time.'),
                    OnboardingView(
                      image: 'assets/images/onboarding2.png', 
                      title: 'Keep your health on track', 
                      description: 'Track your health and stay on top of your daily habits.'),
                      OnboardingView(
                        image: 'assets/images/onboarding3.png', 
                        title: 'Build healthier habits', 
                        description: 'Create healthy routines and take better care of yourself.')
                ],
                ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: (){

                      }, 
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Appcolors.Primary,
                        ),
                      )),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.sizeOf(context).width*0.1
                        ),
                        child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i =0;i<3;i++)
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4
                            ),
                            width: currentPage==i? 25: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: currentPage == i? Appcolors.Primary : Appcolors.Grey2,
                              borderRadius: BorderRadius.circular(10)
                            ),
                          )
                        ],
                      ),
                        ),
                      
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Appcolors.Primary,
                          elevation: 5,
                          padding: EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 10
                          ),
                        shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        )
                        ),
                        onPressed: (){
                          if(currentPage <2){
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300), 
                              curve: Curves.easeInOut);
                          }else{
                              Navigator.pushNamed(
                                context, 
                                '/signup');

                        }}, 
                        child: Text(
                          currentPage ==2 ? 'Get Started' : 'Next',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Appcolors.White
                          ),
                        )
              ),

                  ],)
          ],
        ) )
      
    );
    
  }
}