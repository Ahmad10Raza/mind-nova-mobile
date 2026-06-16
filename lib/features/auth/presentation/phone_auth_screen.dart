import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_text_field.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();

  void _handleVerify() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    // Ensure E.164 format (assuming India +91 if no country code provided)
    if (!phone.startsWith('+')) {
      // Remove leading zero if any
      if (phone.startsWith('0')) {
        phone = phone.substring(1);
      }
      phone = '+91$phone';
    }

    await ref.read(authProvider.notifier).verifyPhoneNumber(phone);
    if (mounted) {
      context.push('/otp-verification', extra: {'identifier': phone, 'isPasswordReset': false});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFFFFDE7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF5E4B8B)),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Mobile Number',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF5E4B8B),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter your mobile number to receive\na verification code',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                const SizedBox(height: 48),
                AuthTextField(
                  controller: _phoneController,
                  hintText: 'Mobile Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  isUnderline: true,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 250,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E4B8B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: authState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'GET OTP',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
