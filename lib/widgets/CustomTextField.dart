import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocal_emotion/utils/colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final FocusNode focusNode;
  final IconData prefixIcon;
  final VoidCallback? onSuffixIconPressed;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    required this.focusNode,
    required this.prefixIcon,
    this.onSuffixIconPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        // Update the border color based on focus if needed
      },
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: AppColors.boxcolor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(
              color: focusNode.hasFocus
                  ? Colors.green
                  : Colors.grey, // Default color when not focused
            ),
          ),
          prefixIcon: Icon(prefixIcon, color: Colors.grey),
          suffixIcon: onSuffixIconPressed != null
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onSuffixIconPressed,
                )
              : null,
        ),
      ),
    );
  }
}
