import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/therapist_dashboard_provider.dart';
import '../../therapist/models/therapist_model.dart';
import '../../auth/providers/auth_provider.dart';
// Colors & Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _errorColor = Color(0xFFFFB4AB);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

class TherapistDashboardScreen extends ConsumerStatefulWidget {
  const TherapistDashboardScreen({super.key});

  @override
  ConsumerState<TherapistDashboardScreen> createState() => _TherapistDashboardScreenState();
}

class _TherapistDashboardScreenState extends ConsumerState<TherapistDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final dashboardStateAsync = ref.watch(therapistDashboardProvider);

    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(top: -100, right: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          Positioned(bottom: -50, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.05), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: const SizedBox()))),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  sliver: dashboardStateAsync.when(
                    loading: () => const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: _primaryColor)),
                    ),
                    error: (error, stack) => SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Error loading dashboard:\n$error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: _errorColor),
                        ),
                      ),
                    ),
                    data: (state) {
                      final pendingRequests = state.pendingRequests;
                      final upcomingSessions = state.upcomingSessions;
                      final completedSessions = state.completedSessions;
                      
                      return SliverList(
                        delegate: SliverChildListDelegate([
                          _buildWelcomeSection(pendingRequests.length, upcomingSessions.length),
                          const SizedBox(height: 32),
                          _buildStatsRow(pendingRequests.length, upcomingSessions.length),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Pending Requests', pendingRequests.length.toString()),
                          const SizedBox(height: 16),
                          if (pendingRequests.isEmpty)
                            _buildEmptyState('No pending requests')
                          else
                            ...pendingRequests.map((req) => _buildPendingRequestCard(req as Map<String, dynamic>)),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Upcoming Sessions', upcomingSessions.length.toString()),
                          const SizedBox(height: 16),
                          if (upcomingSessions.isEmpty)
                            _buildEmptyState('No upcoming sessions today')
                          else
                            ...upcomingSessions.map((session) => _buildUpcomingSessionCard(session as Map<String, dynamic>)),
                          const SizedBox(height: 32),
                          _buildSectionHeader('Completed Sessions', completedSessions.length.toString()),
                          const SizedBox(height: 16),
                          if (completedSessions.isEmpty)
                            _buildEmptyState('No completed sessions yet')
                          else
                            ...completedSessions.map((session) => _buildCompletedSessionCard(session as Map<String, dynamic>)),
                          const SizedBox(height: 48),
                        ]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: _primaryColor), onPressed: () => context.pop()),
      title: Text('Therapist Portal', style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: _primaryColor)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFFC9C4D0)),
          onPressed: () => ref.read(therapistDashboardProvider.notifier).refresh(),
        ),
      ],
      flexibleSpace: ClipRect(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container(decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.8), border: Border(bottom: BorderSide(color: const Color(0xFF353946).withValues(alpha: 0.3))))))),
    );
  }

  Widget _buildWelcomeSection(int pendingCount, int upcomingCount) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : (hour < 17 ? 'Good Afternoon' : 'Good Evening');
    final authState = ref.read(authProvider);
    final name = authState.displayName ?? 'Doctor';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$greeting, $name', style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 8),
        Text('You have $pendingCount new request${pendingCount == 1 ? '' : 's'} and $upcomingCount session${upcomingCount == 1 ? '' : 's'}.', style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFC9C4D0))),
      ],
    );
  }

  Widget _buildStatsRow(int pendingCount, int sessionCount) {
    final totalSessions = pendingCount + sessionCount;
    return Row(
      children: [
        Expanded(child: _buildStatCard('Sessions', '$totalSessions', Icons.schedule)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Pending', '$pendingCount', Icons.pending_actions)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Today', '$sessionCount', Icons.calendar_today)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _glassBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: _secondaryColor, size: 24),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFC9C4D0))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
          child: Text(badge, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: _primaryColor)),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: const Color(0xFF1B1F2C).withValues(alpha: 0.5), borderRadius: BorderRadius.circular(16), border: Border.all(color: _glassBorder, style: BorderStyle.solid)),
      child: Text(text, style: GoogleFonts.inter(color: const Color(0xFFC9C4D0))),
    );
  }

  String _getPatientName(Map<String, dynamic> data) {
    final patient = data['patient'];
    if (patient != null && patient['profile'] != null) {
      final profile = patient['profile'];
      final first = profile['firstName'] ?? '';
      final last = profile['lastName'] ?? '';
      final fullName = '$first $last'.trim();
      if (fullName.isNotEmpty) return fullName;
    }
    return patient?['email'] ?? 'Unknown Patient';
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'No Date';
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      return DateFormat('EEEE, h:mm a').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  Widget _buildPendingRequestCard(Map<String, dynamic> request) {
    final patientName = _getPatientName(request);
    final dateStr = _formatDate(request['scheduledStartTime'] ?? request['date']);
    final typeStr = request['type'] ?? 'Session';
    final reasonStr = request['notes'] ?? 'No reason provided';
    final isUrgent = false; // Defaulted to false unless backend provides an urgency flag
    final appointmentId = request['id'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUrgent ? _errorColor.withValues(alpha: 0.05) : const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUrgent ? _errorColor.withValues(alpha: 0.3) : _glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _primaryColor.withValues(alpha: 0.2),
                    child: Text(
                      patientName.isNotEmpty ? patientName[0].toUpperCase() : '?',
                      style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patientName, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text(typeStr, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFC9C4D0))),
                    ],
                  ),
                ],
              ),
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: _errorColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('Urgent', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: _errorColor)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: _secondaryColor),
              const SizedBox(width: 8),
              Text(dateStr, style: GoogleFonts.inter(fontSize: 14, color: _secondaryColor, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF353946).withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
            child: Text('"$reasonStr"', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFFC9C4D0), fontStyle: FontStyle.italic)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(therapistDashboardProvider.notifier).declineRequest(appointmentId);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF353946)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(therapistDashboardProvider.notifier).acceptRequest(appointmentId);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: const Color(0xFF32285E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingSessionCard(Map<String, dynamic> session) {
    final patientName = _getPatientName(session);
    final timeStr = _formatDate(session['scheduledStartTime'] ?? session['date']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _glassBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _primaryColor.withValues(alpha: 0.2),
                child: Text(
                  patientName.isNotEmpty ? patientName[0].toUpperCase() : '?',
                  style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text(timeStr, style: GoogleFonts.inter(fontSize: 12, color: _secondaryColor)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final patientId = session['patientId'] ?? (session['patient'] != null ? session['patient']['id'] : 'unknown');
                final therapistId = session['therapistId'] ?? (session['therapist'] != null ? session['therapist']['id'] : 'unknown');
                final roomId = 'room_${patientId}_${therapistId}';
                context.push('/therapist/session/live', extra: {
                  'isTherapistRole': true,
                  'remoteName': patientName,
                  'roomId': roomId,
                  'appointmentId': session['id'],
                });
              },
              icon: const Icon(Icons.videocam, size: 20),
              label: const Text('Join Video Call', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _secondaryColor,
                foregroundColor: _backgroundDeep,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to chat with patient
                    // For therapist->patient chat, we pass the patient's userId as the profile id
                    final patientId = session['patientId'] ?? (session['patient'] != null ? session['patient']['id'] : '');
                    final patientUserId = session['patient'] != null ? (session['patient']['id'] ?? '') : patientId;
                    context.push('/therapist/profile/chat', extra: TherapistProfile(
                      id: patientUserId,
                      userId: patientUserId,
                      name: patientName,
                      title: 'Patient',
                      specialty: '',
                      languages: [],
                      hourlyRate: 0,
                      bio: '',
                      styleTags: [],
                      isVerified: true,
                      experienceYrs: 0,
                      rating: 5.0,
                      responseTime: '',
                    ));
                  },
                  icon: const Icon(Icons.chat_bubble, size: 18),
                  label: const Text('Message', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _secondaryColor.withValues(alpha: 0.2),
                    foregroundColor: _secondaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final patientId = session['patientId'] ?? (session['patient'] != null ? session['patient']['id'] : '');
                    context.push('/therapist/portal/insight', extra: {
                      'patientName': patientName,
                      'patientId': patientId,
                    });
                  },
                  icon: const Icon(Icons.analytics, size: 18),
                  label: const Text('Insights', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor.withValues(alpha: 0.2),
                    foregroundColor: _primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildCompletedSessionCard(Map<String, dynamic> session) {
    final patientName = _getPatientName(session);
    final timeStr = _formatDate(session['scheduledStartTime'] ?? session['date']);
    
    final aiSummary = session['aiSummary'] ?? 'No AI summary generated.';
    final rawNotes = session['notes'] ?? 'No raw notes available.';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _secondaryColor.withValues(alpha: 0.2),
                child: const Icon(Icons.check_circle, color: _secondaryColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patientName, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                    Text(timeStr, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFC9C4D0))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('AI Summary', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryColor)),
          const SizedBox(height: 4),
          Text(aiSummary, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 12),
          Text('Raw Notes', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: _primaryColor)),
          const SizedBox(height: 4),
          Text(rawNotes, style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }
}

