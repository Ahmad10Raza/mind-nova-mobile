import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../services/profile_service.dart';

/// Mental Health Discovery Screen — collects baseline profile data
/// for personalised AI analysis after initial authentication.
class MentalHealthOnboardingScreen extends ConsumerStatefulWidget {
  const MentalHealthOnboardingScreen({super.key});

  @override
  ConsumerState<MentalHealthOnboardingScreen> createState() =>
      _MentalHealthOnboardingScreenState();
}

class _MentalHealthOnboardingScreenState
    extends ConsumerState<MentalHealthOnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 3;

  // Step 1 — Demographics
  String? _selectedAgeRange;
  String? _selectedGender;
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  // Step 2 — Goals (multi-select)
  final Set<String> _selectedGoals = {};

  // Step 3 — Baseline
  double _stressLevel = 5;
  double _sleepQuality = 5;
  double _overallMood = 5;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _ageRanges = [
    '13–17',
    '18–24',
    '25–34',
    '35–44',
    '45–54',
    '55–64',
    '65+',
  ];

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Non-binary',
    'Prefer not to say',
  ];

  final List<Map<String, dynamic>> _goalOptions = [
    {'label': 'Reduce Anxiety', 'icon': Icons.spa_rounded, 'color': const Color(0xFF81C784)},
    {'label': 'Manage Stress', 'icon': Icons.self_improvement_rounded, 'color': const Color(0xFF64B5F6)},
    {'label': 'Improve Sleep', 'icon': Icons.nights_stay_rounded, 'color': const Color(0xFF7986CB)},
    {'label': 'Boost Mood', 'icon': Icons.wb_sunny_rounded, 'color': const Color(0xFFFFD54F)},
    {'label': 'Build Resilience', 'icon': Icons.shield_rounded, 'color': const Color(0xFFFF8A65)},
    {'label': 'Focus & Productivity', 'icon': Icons.track_changes_rounded, 'color': const Color(0xFF4DD0E1)},
    {'label': 'Manage Depression', 'icon': Icons.favorite_rounded, 'color': const Color(0xFFE57373)},
    {'label': 'Self-Discovery', 'icon': Icons.explore_rounded, 'color': const Color(0xFFBA68C8)},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _submitProfile();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedAgeRange != null && 
               _selectedGender != null && 
               _weightController.text.isNotEmpty && 
               _heightController.text.isNotEmpty;
      case 1:
        return _selectedGoals.isNotEmpty;
      case 2:
        return true; // Sliders always have values
      default:
        return false;
    }
  }

  Future<void> _submitProfile() async {
    final authStatus = ref.read(authProvider).status;
    final isGuest = authStatus == AuthStatus.anonymous;

    // Send data to /users/profile endpoint on the backend (only for registered users)
    if (!isGuest) {
      try {
        final success = await ref.read(profileServiceProvider).updateProfile(
              ageRange: _selectedAgeRange,
              gender: _selectedGender,
              goals: _selectedGoals.toList(),
              baselineStress: _stressLevel,
              baselineSleep: _sleepQuality,
              baselineMood: _overallMood,
              weight: double.tryParse(_weightController.text),
              height: double.tryParse(_heightController.text),
            );

        if (!mounted) return;

        if (success) {
          // Retrieve the most recent profile to get the real name if available
          final profile = await ref.read(profileServiceProvider).getProfile();
          if (profile != null) {
            final fullName = '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
            if (fullName.isNotEmpty) {
              await ref.read(authProvider.notifier).updateDisplayName(fullName);
            }
          }
        }
      } catch (e) {
        debugPrint("Profile save error: $e");
      }
    } else {
      // Guest-specific local save logic can be added here if needed beyond markProfileCompleted
      // For now, markProfileCompleted already saves to SharedPreferences
    }

    if (!mounted) return;

    // Mark the profile as completed locally
    await ref.read(authProvider.notifier).markProfileCompleted();
    
    if (mounted) {
      context.go('/');
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Exit Setup?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Your progress will be lost. You can restart the setup anytime from the welcome screen.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _exitOnboarding();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              'Exit',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exitOnboarding() async {
    // Logging out returns the user to the Welcome screen via router redirects
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E5F5),
              Color(0xFFEDE7F6),
              Color(0xFFF8F9FA),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                // ─── Top Bar ──────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        GestureDetector(
                          onTap: _prevStep,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 18,
                              color: Color(0xFF5E4B8B),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 36),
                      const Spacer(),
                      Text(
                        'Step ${_currentStep + 1} of $_totalSteps',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5E4B8B),
                        ),
                      ),
                      IconButton(
                        onPressed: _showExitConfirmation,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 24,
                          color: Color(0xFF5E4B8B),
                        ),
                        tooltip: 'Exit Setup',
                      ),
                    ],
                  ),
                ),

                // ─── Progress Bar ─────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / _totalSteps,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5E4B8B)),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Page View ────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildDemographicsStep(),
                      _buildGoalsStep(),
                      _buildBaselineStep(),
                    ],
                  ),
                ),

                // ─── Bottom CTA ──────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _canProceed ? _nextStep : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5E4B8B),
                        disabledBackgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep == _totalSteps - 1 ? 'Complete Setup' : 'Continue',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
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

  // ═══════════════════════════════════════════════════════════════
  //  STEP 1: Demographics
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDemographicsStep() {
    final authStatus = ref.watch(authProvider).status;
    final isGuest = authStatus == AuthStatus.anonymous;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            isGuest ? 'Welcome, Guest!' : 'Tell Us About You',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isGuest 
              ? "We're glad you're here. Let's set up a few basics to personalize your guest experience."
              : 'This helps us personalise your experience and provide age-appropriate recommendations.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF8E8E93),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Age Range
          Text(
            'Age Range',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _ageRanges.map((age) {
              final isSelected = _selectedAgeRange == age;
              return GestureDetector(
                onTap: () => setState(() => _selectedAgeRange = age),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF5E4B8B)
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF5E4B8B)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF5E4B8B).withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    age,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Gender
          Text(
            'Gender',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _genderOptions.map((gender) {
              final isSelected = _selectedGender == gender;
              return GestureDetector(
                onTap: () => setState(() => _selectedGender = gender),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF5E4B8B)
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF5E4B8B)
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF5E4B8B).withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    gender,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF1C1C1E),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Weight & Height
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight (kg)',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStepTextField(
                      controller: _weightController,
                      hint: '00',
                      icon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Height (cm)',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1C1C1E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStepTextField(
                      controller: _heightController,
                      hint: '000',
                      icon: Icons.height_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStepTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1C1C1E),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: const Color(0xFF5E4B8B), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  STEP 2: Goals
  // ═══════════════════════════════════════════════════════════════

  Widget _buildGoalsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'What Brings You Here?',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply. This helps our AI understand your priorities.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF8E8E93),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ..._goalOptions.map((goal) {
            final isSelected = _selectedGoals.contains(goal['label']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedGoals.remove(goal['label']);
                    } else {
                      _selectedGoals.add(goal['label'] as String);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (goal['color'] as Color).withOpacity(0.12)
                        : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? (goal['color'] as Color)
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: (goal['color'] as Color).withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (goal['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          goal['icon'] as IconData,
                          color: goal['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          goal['label'] as String,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1C1C1E),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? goal['color'] as Color
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? goal['color'] as Color
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  STEP 3: Baseline
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBaselineStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Your Current State',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Rate how you have been feeling over the past week. This creates your baseline for tracking progress.",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF8E8E93),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 36),

          _buildSliderCard(
            title: 'Stress Level',
            subtitle: 'How stressed have you felt?',
            value: _stressLevel,
            lowLabel: 'Very Low',
            highLabel: 'Very High',
            activeColor: const Color(0xFFFF8A65),
            icon: Icons.local_fire_department_rounded,
            onChanged: (v) => setState(() => _stressLevel = v),
          ),
          const SizedBox(height: 20),

          _buildSliderCard(
            title: 'Sleep Quality',
            subtitle: 'How well have you been sleeping?',
            value: _sleepQuality,
            lowLabel: 'Poor',
            highLabel: 'Excellent',
            activeColor: const Color(0xFF7986CB),
            icon: Icons.bedtime_rounded,
            onChanged: (v) => setState(() => _sleepQuality = v),
          ),
          const SizedBox(height: 20),

          _buildSliderCard(
            title: 'Overall Mood',
            subtitle: 'How would you rate your general mood?',
            value: _overallMood,
            lowLabel: 'Low',
            highLabel: 'Great',
            activeColor: const Color(0xFF81C784),
            icon: Icons.emoji_emotions_rounded,
            onChanged: (v) => setState(() => _overallMood = v),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String subtitle,
    required double value,
    required String lowLabel,
    required String highLabel,
    required Color activeColor,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: activeColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: activeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1C1C1E),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.round().toString(),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: activeColor,
              inactiveTrackColor: activeColor.withOpacity(0.15),
              thumbColor: activeColor,
              overlayColor: activeColor.withOpacity(0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lowLabel,
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFAEAEB2)),
              ),
              Text(
                highLabel,
                style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFAEAEB2)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
