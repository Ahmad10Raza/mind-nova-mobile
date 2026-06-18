import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/focus_provider.dart';
import '../../models/focus_model.dart';
import 'package:mind_nova_mobile/features/audio/domain/audio_model.dart';
import 'package:mind_nova_mobile/core/constants/app_colors.dart';
import '../widgets/focus_orb.dart';
import '../widgets/audio_selector_sheet.dart';

class FocusTimerScreen extends ConsumerStatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen> {
  final TextEditingController _intentController = TextEditingController();
  FocusMode _selectedMode = FocusMode.deepWork;
  late int _selectedMinutes = _selectedMode.defaultMinutes;
  AudioTrack? _selectedTrack;

  @override
  Widget build(BuildContext context) {
    final focusState = ref.watch(focusProvider);

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), 
              Color(0xFF1E1B4B), 
              Color(0xFF312E81), 
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                  child: Column(
                    children: [
                      const Center(child: FocusOrb()),
                      const SizedBox(height: 40),
                      _buildIntentSection(),
                      const SizedBox(height: 32),
                      _buildAudioChips(),
                      const SizedBox(height: 32),
                      _buildModeSelection(),
                      const SizedBox(height: 40),
                      _buildStartButton(),
                      const SizedBox(height: 32),
                      _buildStatsSummary(focusState),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      floating: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/tools');
          }
        },
      ),
      title: Text(
        'ZEN FOCUS',
        style: GoogleFonts.outfit(
          fontSize: 20,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {}, 
          icon: Icon(Icons.history_rounded, color: Colors.white.withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _buildIntentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHAT MATTERS MOST RIGHT NOW?',
          style: GoogleFonts.outfit(
            fontSize: 12,
            letterSpacing: 1.5,
            color: Colors.white60,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: _intentController,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'e.g., Complete UI Design...',
              hintStyle: GoogleFonts.outfit(color: Colors.white24),
              border: InputBorder.none,
              suffixIcon: Icon(Icons.edit_note, color: Colors.white24, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAudioChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ZEN AMBIENCE',
          style: GoogleFonts.outfit(
            fontSize: 12,
            letterSpacing: 1.5,
            color: Colors.white60,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            final track = await showModalBottomSheet<AudioTrack>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AudioSelectorSheet(initialTrack: _selectedTrack),
            );
            if (track != null) {
              setState(() => _selectedTrack = track);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _selectedTrack != null ? Icons.music_note_rounded : Icons.headset_outlined,
                    color: AppColors.primaryPurpleLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedTrack?.title ?? 'Select Atmosphere',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _selectedTrack != null ? 'Focus with ${_selectedTrack!.category}' : 'Music, nature, or white noise',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FOCUS ARCHETYPE',
          style: GoogleFonts.outfit(
            fontSize: 12,
            letterSpacing: 1.5,
            color: Colors.white60,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: FocusMode.values.length,
            itemBuilder: (context, index) {
              final mode = FocusMode.values[index];
              final isSelected = _selectedMode == mode;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _selectedMode = mode;
                    _selectedMinutes = mode.defaultMinutes;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 130,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryPurple.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryPurple.withOpacity(0.5) : Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mode.displayName,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode.description,
                        maxLines: 2,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.heavyImpact();
            ref.read(focusProvider.notifier).startSession(
              mode: _selectedMode,
              durationMinutes: _selectedMinutes,
              goal: _intentController.text,
              selectedTrack: _selectedTrack,
            );
            context.push('/focus/active');
          },
          borderRadius: BorderRadius.circular(32),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'ENTER FLOW STATE',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSummary(FocusState state) {
    if (state.stats == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('STREAK', '${state.stats!.currentStreak}d', Icons.local_fire_department_rounded),
          Container(width: 1, height: 30, color: Colors.white10),
          _buildStatItem('WEEKLY', '${state.stats!.weeklyMinutes}m', Icons.access_time_rounded),
          Container(width: 1, height: 30, color: Colors.white10),
          _buildStatItem('BEST', '${state.stats!.longestStreak}d', Icons.emoji_events_rounded),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 8,
            letterSpacing: 1,
            color: Colors.white38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
