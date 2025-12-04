import 'package:flutter/material.dart';
import '../utils/constans.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color primaryColor;
  final Color borderColor;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.primaryColor,
    required this.borderColor,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Theme(
        data: ThemeData(
          primaryColor: primaryColor,
          colorScheme: ColorScheme.light(primary: primaryColor),
        ),
        child: TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: primaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade500),
            ),
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
            suffixIcon: suffixIcon,
          ),
        ),
      ),
    );
  }
}
