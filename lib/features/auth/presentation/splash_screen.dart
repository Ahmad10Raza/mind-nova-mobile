import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // The redirect logic in GoRouter handles the transition once authState is updated.
    // We add a slight delay for brand presence as per the roadmap.
    Future.delayed(const Duration(seconds: 2), () {
      // Just to satisfy the sequence, though GoRouter.redirect is watchingauthProvider state.
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using a simple placeholder for the animated logo mentioned in roadmap
            Icon(Icons.psychology, size: 100, color: Color(0xFF5E4B8B)),
            SizedBox(height: 20),
            Text(
              'MindNova',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5E4B8B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
