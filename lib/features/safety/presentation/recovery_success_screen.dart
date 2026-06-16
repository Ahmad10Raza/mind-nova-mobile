import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class RecoverySuccessScreen extends StatelessWidget {
  const RecoverySuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.favorite, color: Colors.purpleAccent, size: 80),
              const SizedBox(height: 32),
              const Text(
                "Glad you're still here 💜",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Take a deep breath. You've made it through a difficult moment.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 64),
              const Text(
                "How do you feel now?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              _buildMoodButton(
                context,
                emoji: '🙂',
                label: 'Better',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  context.go('/'); // Return Home
                },
              ),
              const SizedBox(height: 16),
              _buildMoodButton(
                context,
                emoji: '😐',
                label: 'Same',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.go('/tools'); // Continue Calm
                },
              ),
              const SizedBox(height: 16),
              _buildMoodButton(
                context,
                emoji: '😞',
                label: 'Still Struggling',
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  context.go('/safe-contacts'); // Suggest contacts
                },
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoodButton(
    BuildContext context, {
    required String emoji,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );
  }
}
