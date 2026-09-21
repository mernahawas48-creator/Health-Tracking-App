import 'package:flutter/material.dart';
import 'package:meditrack/features/authview.dart';
import 'package:meditrack/themes/appcolors.dart';
import 'package:meditrack/features/custom_text_form_field.dart';
import 'package:meditrack/l10n/app_strings.dart';
import 'package:meditrack/services/local_session_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return AuthLayout(
      child: Form(key: _formKey, child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.sizeOf(context).width*0.01,
              vertical: MediaQuery.sizeOf(context).height*0.02
            ),
            child:Text(
            strings.text('loginWelcome'),
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
            strings.text('loginSubtitle'),
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
                  LabelText: strings.text('email'),
                  hintText: strings.text('enterEmail'),
                  prefixIcon: Icons.email_outlined,
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return strings.text('enterEmailError');
                    }
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                    if (!emailRegex.hasMatch(value)){
                      return strings.text('validEmailError');
                    }
                    return null;
                  },
              )
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),

            SizedBox(
              width: MediaQuery.sizeOf(context).width *0.9,
              child: CustomTextFormField(
                LabelText: strings.text('password'),
                hintText: '.... .... ....', 
                prefixIcon: Icons.lock_outline,
                validator: (value) {
                    if(value==null || value.isEmpty){
                      return strings.text('enterPasswordError');
                    }
                    if(value.length < 8){
                      return strings.text('passwordLengthError');
                    }
                     if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return strings.text('passwordUppercase');
                    }

                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return strings.text('passwordLowercase');
                    }

                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return strings.text('passwordNumber');
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
              onPressed: () async {
                if (!(_formKey.currentState?.validate() ?? false)) return;
                await LocalSessionService.signIn();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
              }, 
              child: Text(
                strings.text('login'),
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
                    strings.text('orContinue'),
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
                  strings.text('needHelp'),
                  style: TextStyle(
                  color: Appcolors.Primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),)
                
              )

              
        ]
      )));
  }
}
