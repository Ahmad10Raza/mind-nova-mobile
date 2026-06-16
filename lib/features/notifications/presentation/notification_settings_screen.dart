import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/notification_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  Map<String, dynamic> _localState = {};
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(notificationPreferencesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notification Settings',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C1C1E),
          ),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isSaving ? null : _savePreferences,
              child: _isSaving
                  ? const SizedBox(
                      width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF5E4B8B)),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5E4B8B),
                      ),
                    ),
            ),
        ],
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF5E4B8B))),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (prefs) {
          // Initialize local state from server on first load
          if (_localState.isEmpty) {
            _localState = prefs.toJson();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Daily Reminders'),
                const SizedBox(height: 8),
                _buildToggleTile(
                  'Mood Logging',
                  'Get reminded to log your mood daily',
                  Icons.emoji_emotions_rounded,
                  const Color(0xFFF57F17),
                  'moodReminders',
                ),
                _buildToggleTile(
                  'Sleep Tracking',
                  'Bedtime wind-down reminders',
                  Icons.bedtime_rounded,
                  const Color(0xFF7C4DFF),
                  'sleepReminders',
                ),
                _buildToggleTile(
                  'Meditation',
                  'Daily mindfulness practice reminders',
                  Icons.self_improvement_rounded,
                  const Color(0xFF00BCD4),
                  'meditationReminders',
                ),
                _buildToggleTile(
                  'Journaling',
                  'Evening reflection prompts',
                  Icons.edit_note_rounded,
                  const Color(0xFF4CAF50),
                  'journalReminders',
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Insights & Reports'),
                const SizedBox(height: 8),
                _buildToggleTile(
                  'Weekly Report',
                  'When your AI weekly analysis is ready',
                  Icons.auto_awesome_rounded,
                  const Color(0xFF00D2FF),
                  'weeklyReportAlerts',
                ),
                _buildToggleTile(
                  'Assessments',
                  'Periodic mental health check-in reminders',
                  Icons.assignment_rounded,
                  const Color(0xFF2196F3),
                  'assessmentReminders',
                ),
                _buildToggleTile(
                  'Streak Milestones',
                  'Celebrate your logging consistency',
                  Icons.local_fire_department_rounded,
                  const Color(0xFFFF9800),
                  'streakAlerts',
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Social & Therapy'),
                const SizedBox(height: 8),
                _buildToggleTile(
                  'Therapy Reminders',
                  'Appointment reminders for sessions',
                  Icons.person_rounded,
                  const Color(0xFF5E4B8B),
                  'therapyReminders',
                ),
                _buildToggleTile(
                  'Community',
                  'Activity from posts and discussions',
                  Icons.people_rounded,
                  const Color(0xFF3F51B5),
                  'communityAlerts',
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Reminder Times'),
                const SizedBox(height: 8),
                _buildTimePicker('Mood Reminder', 'moodReminderTime'),
                _buildTimePicker('Sleep Reminder', 'sleepReminderTime'),

                const SizedBox(height: 24),
                _buildSectionTitle('Quiet Hours'),
                const SizedBox(height: 8),
                _buildQuietHoursInfo(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1C1C1E),
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String key,
  ) {
    final value = _localState[key] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8E8E93)),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: const Color(0xFF5E4B8B),
            onChanged: (newVal) {
              setState(() {
                _localState[key] = newVal;
                _hasChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, String key) {
    final timeStr = _localState[key] as String? ?? '20:00';
    final parts = timeStr.split(':');
    final tod = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule_rounded, color: Color(0xFF5E4B8B), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1C1C1E),
              ),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: tod,
              );
              if (picked != null) {
                setState(() {
                  _localState[key] =
                      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                  _hasChanges = true;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                tod.format(context),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5E4B8B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.do_not_disturb_on_rounded, color: Color(0xFF8E8E93), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quiet Hours',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1C1C1E),
                  ),
                ),
                Text(
                  '10:00 PM – 7:00 AM (no non-critical alerts)',
                  style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF8E8E93)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    try {
      final service = ref.read(notificationServiceProvider);
      await service.updatePreferences(_localState);
      ref.invalidate(notificationPreferencesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preferences saved!', style: GoogleFonts.inter()),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      setState(() {
        _hasChanges = false;
        _isSaving = false;
      });
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
