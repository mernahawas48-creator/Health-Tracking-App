import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:meditrack/core/services/auth_service.dart';
import 'package:meditrack/core/di/injection.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/core/widgets/custom_text_form_field.dart';

import 'package:meditrack/features/auth/widgets/authview.dart';
import 'package:meditrack/themes/appcolors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ==========================================================
  // SERVICES
  // ==========================================================

  final AuthService _authService = getIt.isRegistered<AuthService>()
      ? getIt<AuthService>()
      : AuthService();

  // ==========================================================
  // CONTROLLERS
  // ==========================================================

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> _login() async {
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

      // Firebase checks:
      // 1. The email belongs to an existing account.
      // 2. The password matches that account.
      await _authService.login(email: email, password: password);

      if (!mounted) return;

      // Successful authentication -> Home
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      _handleLoginError(e);
    } catch (e) {
      if (!mounted) return;

      _showErrorDialog(
        title: 'Login Failed',
        message:
            'Something went wrong.\n\n'
            'Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================================================
  // LOGIN ERRORS
  // ==========================================================

  void _handleLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        _showErrorDialog(
          title: 'Incorrect Email or Password',
          message:
              'The email or password you entered is incorrect.\n\n'
              'Make sure you signed up first and entered '
              'the correct password.',
        );
        break;

      case 'invalid-email':
        _showErrorDialog(
          title: 'Invalid Email',
          message: 'Please enter a valid email address.',
        );
        break;

      case 'user-disabled':
        _showErrorDialog(
          title: 'Account Disabled',
          message: 'This account has been disabled.',
        );
        break;

      case 'too-many-requests':
        _showErrorDialog(
          title: 'Too Many Attempts',
          message:
              'Too many login attempts have been made.\n\n'
              'Please wait a little and try again.',
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

      default:
        _showErrorDialog(
          title: 'Login Failed',
          message:
              'Could not log in.\n\n'
              'Please check your information and try again.',
        );
    }
  }

  // ==========================================================
  // FORGOT PASSWORD
  // ==========================================================

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController(
      text: emailController.text.trim(),
    );

    final formKey = GlobalKey<FormState>();

    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.rightSlide,
      title: 'Forgot Password?',
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Form(
          key: formKey,
          child: TextFormField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            validator: Validators.email,
          ),
        ),
      ),
      btnOkText: 'Send Reset Email',
      btnOkOnPress: () async {
        if (!formKey.currentState!.validate()) {
          return;
        }

        await _sendPasswordReset(resetEmailController.text.trim());

        resetEmailController.dispose();
      },
      btnCancelText: 'Cancel',
      btnCancelOnPress: () {
        resetEmailController.dispose();
      },
    ).show();
  }

  // ==========================================================
  // SEND PASSWORD RESET
  // ==========================================================

  Future<void> _sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        title: 'Email Sent',
        desc:
            'If an account exists with this email, '
            'you will receive a password reset email.\n\n'
            'Please check your inbox and spam folder.',
        btnOkOnPress: () {},
      ).show();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'invalid-email') {
        _showErrorDialog(
          title: 'Invalid Email',
          message: 'Please enter a valid email address.',
        );
      } else {
        _showErrorDialog(
          title: 'Could Not Send Email',
          message:
              'We could not send the reset email.\n\n'
              'Please try again later.',
        );
      }
    } catch (_) {
      if (!mounted) return;

      _showErrorDialog(
        title: 'Something Went Wrong',
        message: 'Please try again later.',
      );
    }
  }

  // ==========================================================
  // ERROR DIALOG
  // ==========================================================

  void _showErrorDialog({required String title, required String message}) {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: size.height * 0.02),

              Text(
                'Hey, Welcome back!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              Text(
                'Glad to see you, Again!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // ==================================================
              // EMAIL
              // ==================================================
              SizedBox(
                width: size.width * 0.9,
                child: CustomTextFormField(
                  controller: emailController,
                  LabelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
              ),

              SizedBox(height: size.height * 0.03),

              // ==================================================
              // PASSWORD
              // ==================================================
              SizedBox(
                width: size.width * 0.9,
                child: CustomTextFormField(
                  controller: passwordController,
                  LabelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: Validators.loginPassword,
                ),
              ),

              // ==================================================
              // FORGOT PASSWORD
              // ==================================================
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: size.width * 0.07),
                  child: TextButton(
                    onPressed: _isLoading ? null : _showForgotPasswordDialog,
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Appcolors.Primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.01),

              // ==================================================
              // LOGIN BUTTON
              // ==================================================
              SizedBox(
                width: size.width * 0.55,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Appcolors.Primary,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Appcolors.White,
                          ),
                        )
                      : const Text(
                          'Log in',
                          style: TextStyle(
                            color: Appcolors.White,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // ==================================================
              // SIGN UP LINK
              // ==================================================
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            Navigator.pushNamed(context, '/signup');
                          },
                    child: const Text('Sign up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
