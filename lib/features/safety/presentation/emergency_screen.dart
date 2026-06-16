import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/safety_provider.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safetyState = ref.watch(safetyProvider);
    final resources = safetyState.resources;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark, serious background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              const Icon(
                Icons.health_and_safety,
                color: Color(0xFFFF5252),
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Help is Available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'You are not alone. There are people who want to support you. Please reach out to one of the resources below.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  children: [
                    const _FamilySupportCard(),
                    ...resources.map((r) => _ResourceCard(resource: r)).toList(),
                    if (resources.isEmpty) ...[
                      const _ManualResourceCard(
                        name: 'Crisis Text Line',
                        description: 'Text HOME to 741741',
                        phoneNumber: '741741',
                      ),
                      const SizedBox(height: 16),
                      const _ManualResourceCard(
                        name: 'Crisis Helpline',
                        description: 'Available 24/7, free and confidential',
                        phoneNumber: '102',
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: safetyState.isLoading 
                      ? null 
                      : () => ref.read(safetyProvider.notifier).resolveCrisis(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: safetyState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('I am safe now'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final dynamic resource;
  const _ResourceCard({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          resource.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            resource.description ?? 'Connect with support resources now.',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFF5252).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.call, color: Color(0xFFFF5252)),
            onPressed: () => launchUrl(Uri.parse('tel:${resource.phoneNumber}')),
          ),
        ),
      ),
    );
  }
}

class _ManualResourceCard extends StatelessWidget {
  final String name;
  final String description;
  final String phoneNumber;

  const _ManualResourceCard({
    required this.name,
    required this.description,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            description,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFF5252).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.call, color: Color(0xFFFF5252)),
            onPressed: () => launchUrl(Uri.parse('tel:$phoneNumber')),
          ),
        ),
      ),
    );
  }
}

class _FamilySupportCard extends StatelessWidget {
  const _FamilySupportCard();

  void _sendMessage() async {
    const message = "Hey, I'm using MindNova and it suggested I reach out. I'm having a bit of a tough time and just wanted to share a positive thought with you. Hope you're doing well! ❤️";
    final Uri smsUri = Uri.parse('sms:?body=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF5E4B8B).withOpacity(0.3),
            const Color(0xFFFF5252).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5E4B8B).withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5E4B8B).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite, color: Color(0xFFFF80AB)),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Talk to Family',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'Send a positive message to a loved one.',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Message Family'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5E4B8B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
