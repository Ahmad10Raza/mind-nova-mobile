import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A premium social authentication button with brand-specific icon and styling.
class SocialAuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor = Colors.white,
    this.textColor = const Color(0xFF1C1C1E),
    this.borderColor,
  });

  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  /// Factory for the standard Google button.
  factory SocialAuthButton.google({
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SocialAuthButton(
      label: 'Sign in with Google',
      icon: Icons.g_mobiledata_rounded,
      iconColor: Colors.white,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: const Color(0xFFDB4437),
      textColor: Colors.white,
    );
  }

  /// Factory for the standard Mobile button.
  factory SocialAuthButton.mobile({
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SocialAuthButton(
      label: 'Login with Mobile',
      icon: Icons.phone_android_rounded,
      iconColor: Colors.white,
      onPressed: onPressed,
      isLoading: isLoading,
      backgroundColor: const Color(0xFF5E4B8B), // Purple from SS
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: borderColor != null 
              ? BorderSide(color: borderColor!, width: 1.5)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Matching SS
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 28, color: iconColor),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
