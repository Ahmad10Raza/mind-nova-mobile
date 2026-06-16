import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/group_provider.dart';

class GroupOnboardingScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupOnboardingScreen({super.key, required this.groupId});

  @override
  ConsumerState<GroupOnboardingScreen> createState() => _GroupOnboardingScreenState();
}

class _GroupOnboardingScreenState extends ConsumerState<GroupOnboardingScreen> {
  String _selectedCommitment = 'DAILY';
  final TextEditingController _goalController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, String>> _commitmentOptions = [
    {
      'id': 'DAILY',
      'title': 'Daily Check-in',
      'desc': 'I will log my mood every day to support the circle.',
    },
    {
      'id': 'WEEKLY',
      'title': 'Weekly Deep-dive',
      'desc': 'I will share a detailed reflection once a week.',
    },
    {
      'id': 'FLEXIBLE',
      'title': 'Flexible Support',
      'desc': 'I will participate whenever I feel I need help or can help.',
    },
  ];

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupDetail = ref.watch(groupDetailProvider(widget.groupId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: groupDetail.when(
        data: (group) => SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to the Circle',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Before you enter ${group.title}, let\'s set your intention for this safe space.',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              _buildSectionTitle('YOUR COMMITMENT'),
              const SizedBox(height: 16),
              ..._commitmentOptions.map((opt) => _buildCommitmentCard(opt)).toList(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('WHAT IS YOUR GOAL? (OPTIONAL)'),
              const SizedBox(height: 16),
              TextField(
                controller: _goalController,
                style: GoogleFonts.inter(color: Colors.white),
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'e.g., "I want to manage my social anxiety..."',
                  hintStyle: GoogleFonts.inter(color: Colors.white12),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              
              const SizedBox(height: 40),
              _buildRulesSection(group.rules),
              
              const SizedBox(height: 40),
              _buildSubmitButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: const Color(0xFFB388FF),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildCommitmentCard(Map<String, String> opt) {
    final isSelected = _selectedCommitment == opt['id'];
    return GestureDetector(
      onTap: () => setState(() => _selectedCommitment = opt['id']!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB388FF).withOpacity(0.1) : const Color(0xFF1A1A1E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFFB388FF) : Colors.white.withOpacity(0.05),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opt['title']!,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opt['desc']!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFFB388FF)),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesSection(String? rules) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1E),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded, color: Color(0xFF81C784), size: 20),
              const SizedBox(width: 12),
              Text(
                'Circle Safety Rules',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            rules ?? '1. Be kind and respectful.\n2. No medical advice.\n3. Respect privacy.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white70,
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submitOnboarding,
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB388FF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  'ENTER CIRCLE',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _submitOnboarding() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(groupServiceProvider).completeOnboarding(
        widget.groupId,
        _selectedCommitment,
        _goalController.text,
      );
      
      if (mounted) {
        ref.invalidate(groupDetailProvider(widget.groupId));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
