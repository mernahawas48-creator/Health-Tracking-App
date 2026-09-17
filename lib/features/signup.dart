import 'package:flutter/material.dart';
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.sizeOf(context).height*0.1,
              left: MediaQuery.sizeOf(context).width*0.05
            ),
            child:Text.rich(
                TextSpan(
                  children:[
                    TextSpan(
                      text: 'Let\'s ',
                      style: TextStyle(
                        color: Color(0xff00a1a9),
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic
                  )
                ),
                TextSpan(
                  text: 'Create your profile',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500
                  )
                )
              ] )
          )
          ),

          SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),

          
        ],

      ),

    );
  }
}