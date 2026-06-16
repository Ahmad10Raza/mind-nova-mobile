import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design/colors/app_colors.dart';

/// A premium text field with icon, validation, and focus-aware borders.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.isUnderline = false,
  });

  final bool isUnderline;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscured,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: GoogleFonts.inter(
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
        prefixIcon: Icon(
          widget.prefixIcon,
          color: AppColors.novaPurpleLight,
          size: 22,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        filled: !widget.isUnderline,
        fillColor: widget.isUnderline ? Colors.transparent : AppColors.surfaceSecondary,
        contentPadding: widget.isUnderline 
            ? const EdgeInsets.symmetric(horizontal: 0, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: widget.isUnderline 
            ? UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary, width: 1))
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
        enabledBorder: widget.isUnderline
            ? UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary, width: 1))
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.2), width: 1),
              ),
        focusedBorder: widget.isUnderline
            ? UnderlineInputBorder(borderSide: BorderSide(color: AppColors.novaPurpleLight, width: 2))
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.novaPurpleLight, width: 2),
              ),
        errorBorder: widget.isUnderline
            ? UnderlineInputBorder(borderSide: BorderSide(color: AppColors.error, width: 1))
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.error, width: 1.5),
              ),
        focusedErrorBorder: widget.isUnderline
            ? UnderlineInputBorder(borderSide: BorderSide(color: AppColors.error, width: 2))
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.error, width: 2),
              ),
      ),
    );
  }
}
