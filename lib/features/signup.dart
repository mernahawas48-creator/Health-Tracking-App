import 'package:flutter/material.dart';
import 'package:meditrack/features/authview.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/features/custom_text_form_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPage();
}

class _SignupPage extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsetsGeometry.symmetric(
              vertical: MediaQuery.sizeOf(context).width*0.05
            ) ,
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: 'Let\'s',
                  style: TextStyle(
                    color: Appcolors.Primary,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 30
                  )
                ),
                TextSpan(
                  text: ' Sign up',
                  style: TextStyle(
                    color: Appcolors.Black,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    fontSize: 25
                  )
                ),
              ])
            ),
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width *0.9,
              child: CustomTextFormField(
                LabelText: 'First Name', 
                hintText: 'Enter your first name', 
                prefixIcon: Icons.person
                ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),
            SizedBox(
              width: MediaQuery.sizeOf(context).width *0.9,
              child: CustomTextFormField(
                LabelText: 'Last Name', 
                hintText: 'Enter your last name', 
                prefixIcon: Icons.person
                ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),
            SizedBox(
              width: MediaQuery.sizeOf(context).width *0.9,
              child: CustomTextFormField(
                  LabelText: 'Email', 
                  hintText: 'Enter your email', 
                  prefixIcon: Icons.email_outlined,
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                    if (!emailRegex.hasMatch(value)){
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
              )
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),

            SizedBox(
              width: MediaQuery.sizeOf(context).width *0.9,
              child: CustomTextFormField(
                LabelText: 'Password', 
                hintText: '.... .... ....', 
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                    if(value==null || value.isEmpty){
                      return 'Please enter your password';
                    }
                    if(value.length < 8){
                      return 'Password must be at least 8 characters';
                    }
                     if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Password must contain an uppercase letter';
                    }

                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Password must contain a lowercase letter';
                    }

                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Password must contain a number';
                    }

                    return null;
                  } ,

                ),
            )
          
        ],

      ) 
      );
  }
}