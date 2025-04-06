import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  const MyTextfield({
    super.key,
    required this.controller,
    required this.autocorrect,
    required this.obscureText,
    required this.keyboardType,
    required this.labelText,
    required this.prefixIcon,
  });

  final TextEditingController controller;
  final bool autocorrect;
  final bool obscureText;
  final TextInputType keyboardType;
  final String labelText;
  final Widget prefixIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        autocorrect: autocorrect,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: prefixIcon,
          labelText: labelText,
          // labelStyle: const TextStyle(color: Colors.red),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
