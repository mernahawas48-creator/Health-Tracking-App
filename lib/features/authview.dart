import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';

class AuthLayout extends StatelessWidget{
  final Widget child;
  const AuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Appcolors.Primary ,
      body: Stack(
        children: [
          Positioned(
            top: size.height*0.12,
            left: size.width*0.3,
            child: Image.asset(
              'assets/images/get_started1.png', 
            )
            ),
            Positioned(
              top: size.height*0.17,
              left: size.width*0.02,
              child: Image.asset(
                'assets/images/get_started2.png'
              ) 
              ),
              Positioned(
                top: size.height*0.1,
                left: size.width*0.1,
                child: Text(
                  '“Right Dose \nAlways”',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Appcolors.White
                  ),
              )
              ),

              Positioned(
                top: size.height*0.32,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                    decoration:BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Appcolors.White

                    ) ,
                    child: child,
                ))
        ],
      ),


    );
  }

}