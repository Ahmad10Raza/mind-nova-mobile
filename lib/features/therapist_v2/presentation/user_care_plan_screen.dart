import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../therapist/providers/therapist_provider.dart';
import '../../therapist/models/therapist_model.dart';

// Colors & Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

class UserCarePlanScreen extends ConsumerWidget {
  const UserCarePlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(userSessionsProvider);

    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(top: -100, right: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          Positioned(bottom: -50, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.05), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: const SizedBox()))),
          
          SafeArea(
            child: sessionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: _primaryColor)),
              error: (err, stack) => Center(child: Text('Error loading care plan: $err', style: const TextStyle(color: Colors.white))),
              data: (sessionsMap) {
                final upcoming = sessionsMap['upcoming'] ?? [];
                // Sort upcoming sessions so the nearest one is first
                upcoming.sort((a, b) => a.date.compareTo(b.date));
                final activeSession = upcoming.isNotEmpty ? upcoming.first : null;

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(context),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHeader(context, activeSession),
                          const SizedBox(height: 32),
                          if (activeSession != null) ...[
                            _buildNovaFollowUpCard(activeSession.therapistName),
                            const SizedBox(height: 32),
                          ],
                          _buildSectionTitle('Assigned Tasks'),
                          const SizedBox(height: 16),
                          _buildAssignedTasks(activeSession != null),
                          const SizedBox(height: 32),
                          _buildSectionTitle('Upcoming Sessions'),
                          const SizedBox(height: 16),
                          _buildUpcomingSessionCard(context, activeSession),
                          const SizedBox(height: 48),
                        ]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: _primaryColor), onPressed: () => context.pop()),
      title: Text('My Care Plan', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: _primaryColor)),
      centerTitle: true,
      flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.8), border: Border(bottom: BorderSide(color: const Color(0xFF353946).withValues(alpha: 0.3))))))),
    );
  }

  Widget _buildHeader(BuildContext context, UserSession? session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Treatment Journey', style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 8),
        if (session != null) ...[
          Text(
            'Managed in collaboration with ${session.therapistName}', 
            style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0))
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final profile = TherapistProfile.fromJson(session.therapist ?? {});
                context.push('/therapist/profile/chat', extra: profile);
              },
              icon: const Icon(Icons.chat_bubble),
              label: const Text('Message Therapist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondaryColor,
                foregroundColor: _backgroundDeep,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ] else
          Text('No active treatment plan.', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0))),
      ],
    );
  }

  Widget _buildNovaFollowUpCard(String therapistName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text('Nova AI Follow-Up', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: _primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"$therapistName noted your goal to improve sleep continuity. Would you like to start the 10-minute Evening Wind-Down breathing exercise now?"',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontStyle: FontStyle.italic, height: 1.5),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: const Color(0xFF32285E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Start Exercise', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white));
  }

  Widget _buildAssignedTasks(bool hasSession) {
    if (!hasSession) {
      return Text('No tasks assigned yet.', style: GoogleFonts.inter(color: Colors.white54));
    }
    return Column(
      children: [
        _buildTaskTile('Evening Wind-Down Breathing', 'Complete 3 times this week', Icons.air, 1, 3),
        const SizedBox(height: 12),
        _buildTaskTile('Journal: Anxiety Triggers', 'Write one entry about work stress', Icons.book, 0, 1),
      ],
    );
  }

  Widget _buildTaskTile(String title, String subtitle, IconData icon, int completed, int total) {
    final progress = completed / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: _secondaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFC9C4D0))),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: const Color(0xFF353946),
                  color: _secondaryColor,
                  borderRadius: BorderRadius.circular(4),
                  minHeight: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessionCard(BuildContext context, UserSession? session) {
    if (session == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _glassBorder),
        ),
        child: const Center(
          child: Text('No upcoming sessions scheduled.', style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    final day = DateFormat('dd').format(session.date);
    final month = DateFormat('MMM').format(session.date).toUpperCase();
    final startTime = DateFormat('h:mm a').format(session.date);
    final endTime = DateFormat('h:mm a').format(session.date.add(Duration(minutes: session.durationMin)));

    return GestureDetector(
      onTap: () {
        final roomId = 'room_${session.patientId}_${session.therapistId}';
        context.push('/therapist/session/live', extra: {
          'isTherapistRole': false,
          'remoteName': session.therapistName,
          'roomId': roomId,
          'appointmentId': session.id,
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_primaryColor.withValues(alpha: 0.2), const Color(0xFF1B1F2C).withValues(alpha: 0.9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _primaryColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: _backgroundDeep, borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(day, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(month, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: _primaryColor)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${session.type.replaceAll('_', ' ')}', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('$startTime - $endTime', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: const Icon(Icons.videocam, color: _secondaryColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }


}
