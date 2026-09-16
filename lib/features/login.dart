import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff00a1a9),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            left: 120,
            child: Image.asset(
              'assets/images/get_started1.png',
            )
            ),
            Positioned(
              top:140,
              left: 10,
              child: Image.asset(
                'assets/images/get_started2.png'
              )
              ),

              Positioned(
                top:80 ,
                left: 40,
                child: Text(
                  '“Right Dose \nAlways”',
                  style: TextStyle(
                    color: Color(0xffFFFFFF),
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic
                  ),
                ) 
                ),

                Positioned(
                  top:MediaQuery.sizeOf(context).height*0.32 ,
                  left: MediaQuery.sizeOf(context).width*0.001,
                  right: MediaQuery.sizeOf(context).width*0.001,
                  height: MediaQuery.sizeOf(context).height*0.9,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Color(0xffFFFFFF)
                    ),
                    child: Padding(padding: EdgeInsetsGeometry.symmetric(
                      horizontal: MediaQuery.sizeOf(context).width*0.06,
                    ),
                    
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.sizeOf(context).width * 0.02,
      ),

      child: Column(
        children: [

          // Hey, Welcome Back
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.sizeOf(context).height * 0.025,
              ),

              child: Text(
                'Hey, Welcome Back!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xff1A1A1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
          ),

          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.01,
          ),

          // Glad to see you
          SizedBox(
            width: double.infinity,
            child: Text(
              'Glad to see you, Again!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xff1A1A1A),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),

          SizedBox(height: MediaQuery.sizeOf(context).height * 0.06,),

          
          Form(
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  
                  validator: (value){
                    if (value == null || value.isEmpty){
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                    if (!emailRegex.hasMatch(value)){
                      return 'Please enter a valid email';
                    }
                    return null;
                  } ,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xff00a1a9),width: 1.5)
                    ) ,
                    hintText: 'Enter your email address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)
                    )
                  ),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),

                TextFormField(
                  obscureText: !isPasswordVisible,
                  validator:(value) {
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
                  },

                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off,),
                      onPressed: (){
                        setState(() {
                          isPasswordVisible = ! isPasswordVisible;
                        });
                      },
                      ),
                      focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Color(0xff00a1a9),width: 1.5)
                    ) ,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)
                    )

                  ),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.03,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff00a1a9),
                    foregroundColor: Color(0xffE6E6E6),
                    elevation: 5,
                padding: const EdgeInsets.symmetric(
                  horizontal: 120,
                  vertical: 10
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(15)
                )
                    
                  ),
                  onPressed:(){

                }, 
                child: Text(
                  'Log in',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xffFFFFFF),
                  ),
                ) 
                ),

                SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),

                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'If you don\'t have an account, Please ',
                        style: TextStyle(
                          color: Color(0xff1A1A1A),
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        )
                      ),
                      TextSpan(
                        text: 'Create Account',
                        style: TextStyle(
                          color: Color(0xff00a1a9),
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          decoration: TextDecoration.underline,
                          decorationColor: Color(0xff00a1a9),
                          decorationThickness: 2,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {

                          },
                      )
                      
                    ]
                  )
                ),

                SizedBox(height: MediaQuery.sizeOf(context).height * 0.02,),
                
                Row(
            children: [
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1.5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                  "Or continue with",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey.shade300,
                  thickness: 1.5,
                ),
              ),

              ],

          ),
        ],
      ),
   
                    
                    
    )
        ])
                  )
          
      )))],
      ),
    );
  }
}