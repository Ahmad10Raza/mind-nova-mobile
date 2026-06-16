import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/assessment_session_provider.dart';

class AssessmentIntroScreen extends ConsumerStatefulWidget {
  final String assessmentId;
  const AssessmentIntroScreen({super.key, required this.assessmentId});

  @override
  ConsumerState<AssessmentIntroScreen> createState() => _AssessmentIntroScreenState();
}

class _AssessmentIntroScreenState extends ConsumerState<AssessmentIntroScreen> {
  String selectedDepth = 'standard';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF5E4B8B).withOpacity(0.2),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          
          // Use ListView for guaranteed scrollability on any screen size
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              children: [
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: 40),
                
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5E4B8B).withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF5E4B8B).withOpacity(0.5)),
                    ),
                    child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 60),
                  ),
                ),
                const SizedBox(height: 32),
                const Center(
                  child: Text(
                    'Internal Discovery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Understand your inner balance through calibrated clinical insights.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                const Text(
                  'Choose Assessment Depth',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDepthCard(
                  title: 'Short',
                  desc: '5-8 questions • Quick pulse check',
                  value: 'short',
                  icon: Icons.flash_on_rounded,
                ),
                const SizedBox(height: 12),
                _buildDepthCard(
                  title: 'Standard',
                  desc: '10-15 questions • Clinical baseline',
                  value: 'standard',
                  icon: Icons.analytics_rounded,
                ),
                const SizedBox(height: 12),
                _buildDepthCard(
                  title: 'Advanced',
                  desc: '20-30 questions • Deep diagnostic dive',
                  value: 'advanced',
                  icon: Icons.psychology_alt_rounded,
                ),
                const SizedBox(height: 48),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/assessment/${widget.assessmentId}/run', extra: selectedDepth);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5E4B8B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('Begin Discovery', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepthCard({
    required String title,
    required String desc,
    required String value,
    required IconData icon,
  }) {
    final isSelected = selectedDepth == value;
    return GestureDetector(
      onTap: () => setState(() => selectedDepth = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5E4B8B).withOpacity(0.2) : Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF5E4B8B) : Colors.white24,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF5E4B8B).withOpacity(0.4) : Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF5E4B8B)),
          ],
        ),
      ),
    );
  }
}
