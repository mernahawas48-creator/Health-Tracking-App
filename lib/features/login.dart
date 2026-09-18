import 'package:flutter/material.dart';
import 'package:meditrack/features/authview.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/features/custom_text_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width*0.01,
              vertical: MediaQuery.sizeOf(context).height*0.02
            ),
            child:Text(
            'Hey, Welcome back!',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Appcolors.Black
            ),
          ), 
          ),

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width*0.1,
              vertical: MediaQuery.sizeOf(context).height*0.0001
            ),
            child:Text(
            'Glad to see you, Again!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Appcolors.Black
            ),
          ), 
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height*0.05,),
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
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Appcolors.Primary,
                elevation: 5,
                padding: EdgeInsets.symmetric(
                  horizontal: 90,
                  vertical: 10
                ),
               shape:  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)
               )
              ),
              onPressed: (){

              }, 
              child: Text(
                'Log in',
                style: TextStyle(
                  color: Appcolors.White,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              )),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.05,),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Appcolors.Grey1,
                      thickness: 1.5,
                      indent: 20,
                    ) ,),
                  Padding(padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width*0.05,
                  ),
                  child: Text(
                    'or continue with',
                    style: TextStyle(
                      fontSize: 14,
                      color: Appcolors.Black2,
                    ),
                  ),),
                  
                  Expanded(
                    child: Divider(
                    color: Appcolors.Grey1,
                    thickness: 1.5,
                    endIndent: 20,
                  ))
                ],
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: (){

                    },
                    child: Image.asset(
                    'assets/images/google-logo.png',
                    width: 50,
                    height: 50,
                  ) ,
                  )
                  
                ],
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),
              TextButton(
                onPressed: (){

                },
                child: Text(
                  'Need Help?',
                  style: TextStyle(
                  color: Appcolors.Primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),)
                
              )

              
        ]
      ));
  }
}