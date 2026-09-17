import 'package:flutter/material.dart';
import 'package:meditrack/themes/appcolors.dart';

class CustomTextFormField extends StatelessWidget{
  final String LabelText;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key, 
    required this.LabelText, 
    required this.hintText, 
    required this.prefixIcon, 
    this.isPassword = false, 
    this.suffixIcon, 
    this.keyboardType = TextInputType.text, 
    this.validator
    });
  

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: LabelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Appcolors.Primary, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15)
        )

      ),
    );
  }

}