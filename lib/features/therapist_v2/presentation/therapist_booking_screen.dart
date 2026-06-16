import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../therapist/models/therapist_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/api_client.dart';

// Colors & Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _errorCrisis = Color(0xFFFFB4AB);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

class TherapistBookingScreen extends ConsumerStatefulWidget {
  final TherapistProfile profile;
  
  const TherapistBookingScreen({super.key, required this.profile});

  @override
  ConsumerState<TherapistBookingScreen> createState() => _TherapistBookingScreenState();
}

class _TherapistBookingScreenState extends ConsumerState<TherapistBookingScreen> {
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = -1;
  String _sessionType = 'VIDEO_CALL';
  bool _isEmergency = false;
  bool _isSubmitting = false;
  final TextEditingController _notesController = TextEditingController();

  // Dynamic dates: next 5 days starting from today
  late final List<DateTime> _dateOptions;
  
  // Time slots (could be fetched from backend in future)
  final List<String> _times = ['09:00 AM', '10:30 AM', '12:00 PM', '02:00 PM', '04:00 PM', '06:00 PM'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateOptions = List.generate(7, (i) => now.add(Duration(days: i)));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('EEE d').format(date);
  }

  String _formatDateSubtitle(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  DateTime _computeScheduledStart() {
    final selectedDate = _dateOptions[_selectedDateIndex];
    final timeStr = _times[_selectedTimeIndex];
    
    // Parse "09:00 AM" style time
    final parsed = DateFormat('hh:mm a').parse(timeStr);
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      parsed.hour,
      parsed.minute,
    );
  }

  int get _durationMin {
    switch (_sessionType) {
      case 'CHAT': return 30;
      case 'AUDIO_CALL': return 45;
      case 'VIDEO_CALL': return 45;
      default: return 45;
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedTimeIndex == -1) return;

    final authState = ref.read(authProvider);
    final userId = authState.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to book a session.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dio = ref.read(apiClientProvider).dio;
      final scheduledStart = _computeScheduledStart();
      final scheduledEnd = scheduledStart.add(Duration(minutes: _durationMin));

      final response = await dio.post('/therapists/book', data: {
        'patientId': userId,
        'therapistId': widget.profile.id,
        'durationMin': _durationMin,
        'type': _sessionType,
        'scheduledStartTime': scheduledStart.toUtc().toIso8601String(),
        'scheduledEndTime': scheduledEnd.toUtc().toIso8601String(),
        'notes': _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      });

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: _secondaryColor),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Session Request Sent! Your therapist will confirm shortly.')),
                ],
              ),
              backgroundColor: const Color(0xFF1B1F2C),
              duration: const Duration(seconds: 3),
            ),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Booking failed: ${response.statusMessage}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error booking session: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(top: -100, right: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          Positioned(bottom: -50, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.05), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: const SizedBox()))),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTherapistHeader(),
                        const SizedBox(height: 32),
                        Text('Select Date', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 16),
                        _buildDateSelector(),
                        const SizedBox(height: 32),
                        Text('Select Time', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 16),
                        _buildTimeSelector(),
                        const SizedBox(height: 32),
                        Text('Session Type', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 16),
                        _buildSessionTypeSelector(),
                        const SizedBox(height: 32),
                        Text('What would you like to focus on?', style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 16),
                        _buildNotesInput(),
                        const SizedBox(height: 32),
                        _buildEmergencyToggle(),
                        const SizedBox(height: 48),
                        _buildSubmitButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: _primaryColor), onPressed: () => context.pop()),
          Expanded(child: Text('Request Session', textAlign: TextAlign.center, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: _primaryColor))),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTherapistHeader() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(widget.profile.imageUrl ?? '', width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width: 64, height: 64, color: Colors.grey)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.profile.name, style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              Text(widget.profile.title, style: GoogleFonts.inter(fontSize: 14, color: _secondaryColor)),
              const SizedBox(height: 4),
              Text('\$${widget.profile.hourlyRate.toStringAsFixed(0)}/session', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFC9C4D0))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _dateOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final date = _dateOptions[index];
          final isSelected = index == _selectedDateIndex;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedDateIndex = index;
              _selectedTimeIndex = -1; // Reset time when date changes
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? _primaryColor : const Color(0xFF1B1F2C).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? _primaryColor : _glassBorder),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatDateLabel(date),
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? const Color(0xFF32285E) : Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDateSubtitle(date),
                    style: GoogleFonts.inter(fontSize: 11, color: isSelected ? const Color(0xFF32285E).withValues(alpha: 0.7) : const Color(0xFFC9C4D0)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: List.generate(_times.length, (index) {
        final isSelected = index == _selectedTimeIndex;
        return GestureDetector(
          onTap: () => setState(() => _selectedTimeIndex = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? _secondaryColor : const Color(0xFF1B1F2C).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? _secondaryColor : _glassBorder),
            ),
            child: Text(
              _times[index],
              style: GoogleFonts.inter(fontSize: 14, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? const Color(0xFF0F131F) : Colors.white),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSessionTypeSelector() {
    final types = [
      {'label': 'Video', 'icon': Icons.videocam, 'value': 'VIDEO_CALL'},
      {'label': 'Audio', 'icon': Icons.mic, 'value': 'AUDIO_CALL'},
      {'label': 'Chat', 'icon': Icons.chat, 'value': 'CHAT'},
    ];

    return Row(
      children: types.map((type) {
        final isSelected = _sessionType == type['value'];
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _sessionType = type['value'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? _primaryColor.withValues(alpha: 0.1) : const Color(0xFF1B1F2C).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? _primaryColor : _glassBorder),
                ),
                child: Column(
                  children: [
                    Icon(type['icon'] as IconData, color: isSelected ? _primaryColor : const Color(0xFFC9C4D0)),
                    const SizedBox(height: 8),
                    Text(type['label'] as String, style: GoogleFonts.inter(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? _primaryColor : const Color(0xFFC9C4D0))),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesInput() {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        hintText: 'Share a brief note to help your therapist prepare...',
        hintStyle: GoogleFonts.inter(color: const Color(0xFFC9C4D0).withValues(alpha: 0.5)),
        filled: true,
        fillColor: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: _primaryColor)),
      ),
    );
  }

  Widget _buildEmergencyToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isEmergency ? _errorCrisis.withValues(alpha: 0.1) : const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isEmergency ? _errorCrisis : _glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _isEmergency ? _errorCrisis.withValues(alpha: 0.2) : const Color(0xFF353946).withValues(alpha: 0.5), shape: BoxShape.circle),
            child: Icon(Icons.warning_amber_rounded, color: _isEmergency ? _errorCrisis : const Color(0xFFC9C4D0)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Urgent Session', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: _isEmergency ? _errorCrisis : Colors.white)),
                Text('Mark this request as high priority', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFC9C4D0))),
              ],
            ),
          ),
          Switch(
            value: _isEmergency,
            onChanged: (val) => setState(() => _isEmergency = val),
            activeColor: _errorCrisis,
            activeTrackColor: _errorCrisis.withValues(alpha: 0.3),
            inactiveThumbColor: const Color(0xFFC9C4D0),
            inactiveTrackColor: const Color(0xFF353946),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _selectedTimeIndex != -1 && !_isSubmitting;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSubmit ? _submitBooking : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          disabledBackgroundColor: const Color(0xFF353946),
          foregroundColor: const Color(0xFF32285E),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSubmitting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF32285E)))
            : Text('Submit Request', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
