import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:meditrack/core/services/auth_service.dart';
import 'package:meditrack/core/di/injection.dart';
import 'package:meditrack/core/utils/validators.dart';
import 'package:meditrack/core/widgets/custom_text_form_field.dart';

import 'package:meditrack/features/auth/widgets/authview.dart';
import 'package:meditrack/features/auth/session_cubit.dart';
import 'package:meditrack/themes/appcolors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Future<void> _continueAfterVerification() async {
    final configured = await context.read<SessionCubit>().prepareAccount();
    if (!mounted) return;
    if (configured == null) throw StateError('No Firebase account.');
    if (!configured) {
      Navigator.pushReplacementNamed(context, '/profileview');
      return;
    }
    final signedIn = await context.read<SessionCubit>().signIn();
    if (!mounted) return;
    if (signedIn) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      _showErrorDialog(title: 'Login Error', message: 'Please try again.');
    }
  }

  final AuthService _authService = getIt.isRegistered<AuthService>()
      ? getIt<AuthService>()
      : AuthService();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      if (mounted) await _continueAfterVerification();
    } catch (_) {
      if (mounted)
        _showErrorDialog(
          title: 'Google sign in failed',
          message: 'Please try again.',
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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

      await _authService.login(email: email, password: password);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Check email verification

      final verified = await _authService.isEmailVerified();

      if (!mounted) return;

      if (!verified) {
        _showVerificationDialog();

        return;
      }

      await _continueAfterVerification();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _handleLoginError(e);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showErrorDialog(
        title: 'Something went wrong',
        message:
            'We could not log you in.\n\n'
            'Please try again later.',
      );
    }
  }

  // ==========================================================
  // LOGIN ERROR
  // ==========================================================

  void _handleLoginError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        _showNoAccountDialog();

        break;

      case 'wrong-password':
        _showErrorDialog(
          title: 'Incorrect Password',
          message:
              'The password you entered is incorrect.\n\n'
              'Please try again.',
        );

        break;

      case 'invalid-credential':
        _showErrorDialog(
          title: 'Incorrect Email or Password',
          message:
              'The email or password you entered is incorrect.\n\n'
              'Please check your information and try again.',
        );

        break;

      case 'invalid-email':
        _showErrorDialog(
          title: 'Invalid Email',
          message: 'Please enter a valid email address.',
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
          message: 'Please check your internet connection.',
        );

        break;

      case 'user-disabled':
        _showErrorDialog(
          title: 'Account Disabled',
          message:
              'This account has been disabled.\n\n'
              'Please contact support.',
        );

        break;

      default:
        _showErrorDialog(
          title: 'Login Failed',
          message:
              'We could not log you in.\n\n'
              'Please try again.',
        );
    }
  }

  // ==========================================================
  // NO ACCOUNT
  // ==========================================================

  void _showNoAccountDialog() {
    AwesomeDialog(
      context: context,

      dialogType: DialogType.warning,

      animType: AnimType.rightSlide,

      title: 'Email Not Found',

      desc:
          'There is no account registered with this email.\n\n'
          'Please sign up first.',

      btnOkText: 'Sign Up',

      btnOkOnPress: () {
        Navigator.pushReplacementNamed(context, '/signup');
      },

      btnCancelText: 'Cancel',

      btnCancelOnPress: () {},
    ).show();
  }

  // ==========================================================
  // FORGOT PASSWORD DIALOG
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

      if (e.code == 'user-not-found') {
        _showNoAccountDialog();
      } else if (e.code == 'invalid-email') {
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
    } catch (e) {
      if (!mounted) return;

      _showErrorDialog(
        title: 'Something Went Wrong',
        message: 'Please try again later.',
      );
    }
  }

  // ==========================================================
  // VERIFICATION
  // ==========================================================

  void _showVerificationDialog() {
    AwesomeDialog(
      context: context,

      dialogType: DialogType.warning,

      animType: AnimType.rightSlide,

      title: 'Email Not Verified',

      desc: 'Please verify your email before logging in.',

      btnOkText: 'Resend Email',

      btnOkOnPress: () async {
        try {
          await _authService.sendVerificationEmail();

          if (!mounted) return;

          AwesomeDialog(
            context: context,

            dialogType: DialogType.success,

            title: 'Email Sent',

            desc: 'A new verification email has been sent.',

            btnOkOnPress: () {},
          ).show();
        } catch (e) {
          if (!mounted) return;

          _showErrorDialog(
            title: 'Failed',
            message: 'Could not resend verification email.',
          );
        }
      },

      btnCancelText: 'Cancel',

      btnCancelOnPress: () {},
    ).show();
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

              // EMAIL
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

              // PASSWORD
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

              // FORGOT PASSWORD
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

              // LOGIN BUTTON
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

              // OR
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerColor,

                      thickness: 1.5,

                      indent: 20,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.05,
                    ),

                    child: Text(
                      'or continue with',

                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  Expanded(
                    child: Divider(
                      color: Theme.of(context).dividerColor,

                      thickness: 1.5,

                      endIndent: 20,
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.02),

              // GOOGLE
              InkWell(
                onTap: _isLoading ? null : _signInWithGoogle,

                borderRadius: BorderRadius.circular(30),

                child: Image.asset(
                  'assets/images/google-logo.png',
                  width: 50,
                  height: 50,
                ),
              ),
              const SizedBox(height: 16),
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
                        : () => Navigator.pushNamed(context, '/signup'),
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
