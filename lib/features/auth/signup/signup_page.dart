import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:meditrack/core/services/auth_service.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/core/widgets/custom_text_form_field.dart';

import 'package:meditrack/features/auth/widgets/authview.dart';
import 'package:meditrack/themes/appcolors.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final AuthService _authService = AuthService();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // SIGN UP
  // ==========================================================

  Future<void> _signUp() async {

    if (_isLoading) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      await _authService.signUp(
        email: email,
        password: password,
      );

      await _authService.sendVerificationEmail();

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showVerificationDialog();

    } on FirebaseAuthException catch (e) {

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _handleSignupError(e);

    } catch (e) {

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showErrorDialog(
        title: 'Something went wrong',
        message:
            'We could not create your account.\n\n'
            'Please try again later.',
      );
    }
  }

  // ==========================================================
  // SIGNUP ERROR
  // ==========================================================

  void _handleSignupError(
    FirebaseAuthException e,
  ) {

    switch (e.code) {

      case 'email-already-in-use':

        _showEmailAlreadyExistsDialog();

        break;

      case 'invalid-email':

        _showErrorDialog(
          title: 'Invalid Email',
          message:
              'Please enter a valid email address.',
        );

        break;

      case 'weak-password':

        _showErrorDialog(
          title: 'Weak Password',
          message:
              'Please choose a stronger password.',
        );

        break;

      case 'network-request-failed':

        _showErrorDialog(
          title: 'No Internet Connection',
          message:
              'Please check your internet connection '
              'and try again.',
        );

        break;

      case 'too-many-requests':

        _showErrorDialog(
          title: 'Too Many Attempts',
          message:
              'Too many requests have been made.\n\n'
              'Please wait a little and try again.',
        );

        break;

      default:

        _showErrorDialog(
          title: 'Sign Up Failed',
          message:
              'We could not create your account.\n\n'
              'Please try again.',
        );
    }
  }

  // ==========================================================
  // EMAIL ALREADY EXISTS
  // ==========================================================

  void _showEmailAlreadyExistsDialog() {

    AwesomeDialog(
      context: context,

      dialogType: DialogType.warning,

      animType: AnimType.rightSlide,

      title: 'Email Already Exists',

      desc:
          'This email is already registered.\n\n'
          'Please log in instead.',

      btnOkText: 'Log In',

      btnOkOnPress: () {

        Navigator.pushReplacementNamed(
          context,
          '/login',
        );
      },

      btnCancelText: 'Cancel',

      btnCancelOnPress: () {},

    ).show();
  }

  // ==========================================================
  // VERIFICATION DIALOG
  // ==========================================================

  void _showVerificationDialog() {

    AwesomeDialog(
      context: context,

      dialogType: DialogType.info,

      animType: AnimType.rightSlide,

      dismissOnTouchOutside: false,

      title: 'Verify Your Email',

      desc:
          'We sent a verification link to:\n\n'
          '${emailController.text.trim()}\n\n'
          'Please verify your email, then come back '
          'to the app.',

      btnOkText: 'I\'ve Verified My Email',

      btnOkOnPress: () {
        _checkEmailVerification();
      },

      btnCancelText: 'Resend Email',

      btnCancelOnPress: () {
        _resendVerificationEmail();
      },

    ).show();
  }

  // ==========================================================
  // CHECK EMAIL
  // ==========================================================

  Future<void> _checkEmailVerification() async {

    try {

      final verified =
          await _authService.isEmailVerified();

      if (!mounted) return;

      if (verified) {

        Navigator.pushReplacementNamed(
          context,
          '/profileview',
        );

      } else {

        _showNotVerifiedDialog();
      }

    } catch (e) {

      if (!mounted) return;

      _showErrorDialog(
        title: 'Verification Error',
        message:
            'We could not check your verification status.\n\n'
            'Please try again.',
      );
    }
  }

  // ==========================================================
  // NOT VERIFIED
  // ==========================================================

  void _showNotVerifiedDialog() {

    AwesomeDialog(
      context: context,

      dialogType: DialogType.warning,

      animType: AnimType.rightSlide,

      title: 'Email Not Verified',

      desc:
          'Your email has not been verified yet.\n\n'
          'Please check your inbox.',

      btnOkText: 'Check Again',

      btnOkOnPress: () {
        _checkEmailVerification();
      },

      btnCancelText: 'Resend Email',

      btnCancelOnPress: () {
        _resendVerificationEmail();
      },

    ).show();
  }

  // ==========================================================
  // RESEND
  // ==========================================================

  Future<void> _resendVerificationEmail() async {

    try {

      await _authService.sendVerificationEmail();

      if (!mounted) return;

      AwesomeDialog(
        context: context,

        dialogType: DialogType.success,

        animType: AnimType.rightSlide,

        title: 'Email Sent',

        desc:
            'A new verification email has been sent.',

        btnOkOnPress: () {},

      ).show();

    } catch (e) {

      if (!mounted) return;

      _showErrorDialog(
        title: 'Failed',
        message:
            'We could not resend the email.\n\n'
            'Please try again later.',
      );
    }
  }

  // ==========================================================
  // ERROR DIALOG
  // ==========================================================

  void _showErrorDialog({
    required String title,
    required String message,
  }) {

    AwesomeDialog(
      context: context,

      dialogType: DialogType.error,

      animType: AnimType.rightSlide,

      title: title,

      desc: message,

      btnOkText: 'OK',

      btnOkOnPress: () {},

    ).show();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.sizeOf(context);

    return AuthLayout(
      child: Form(
        key: _formKey,

        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center,

            children: [

              SizedBox(
                height: size.height * 0.04,
              ),

              const Text(
                'Create Your Account',

                style: TextStyle(
                  fontSize: 28,
                  fontWeight:
                      FontWeight.bold,
                  color: Appcolors.Black,
                ),
              ),

              SizedBox(
                height: size.height * 0.04,
              ),

              // EMAIL

              SizedBox(
                width: size.width * 0.9,

                child: CustomTextFormField(
                  controller:
                      emailController,

                  LabelText: 'Email',

                  hintText:
                      'Enter your email',

                  prefixIcon:
                      Icons.email_outlined,

                  keyboardType:
                      TextInputType.emailAddress,

                  validator:
                      Validators.email,
                ),
              ),

              SizedBox(
                height: size.height * 0.03,
              ),

              // PASSWORD

              SizedBox(
                width: size.width * 0.9,

                child: CustomTextFormField(
                  controller:
                      passwordController,

                  LabelText: 'Password',

                  hintText:
                      'Enter your password',

                  prefixIcon:
                      Icons.lock_outline,

                  isPassword: true,

                  validator:
                      Validators.password,
                ),
              ),

              SizedBox(
                height: size.height * 0.03,
              ),

              // CONFIRM PASSWORD

              SizedBox(
                width: size.width * 0.9,

                child: CustomTextFormField(
                  controller:
                      confirmPasswordController,

                  LabelText:
                      'Confirm Password',

                  hintText:
                      'Enter your password again',

                  prefixIcon:
                      Icons.lock_outline,

                  isPassword: true,

                  validator: (value) {

                    return Validators.confirmPassword(
                      value,
                      passwordController.text,
                    );
                  },
                ),
              ),

              SizedBox(
                height: size.height * 0.04,
              ),

              // SIGN UP BUTTON

              SizedBox(
                width: size.width * 0.55,
                height: 55,

                child: ElevatedButton(

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Appcolors.Primary,

                    elevation: 5,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),

                  onPressed:
                      _isLoading
                          ? null
                          : _signUp,

                  child: _isLoading

                      ? const SizedBox(
                          width: 25,
                          height: 25,

                          child:
                              CircularProgressIndicator(
                            strokeWidth: 3,
                            color:
                                Appcolors.White,
                          ),
                        )

                      : const Text(
                          'Sign up',

                          style: TextStyle(
                            color:
                                Appcolors.White,
                            fontSize: 25,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}