import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_client.dart';

// Colors & Constants
const _backgroundDeep = Color(0xFF0F131F);
const _primaryColor = Color(0xFFE6DEFF);
const _secondaryColor = Color(0xFF40E0CB);
const _glassBorder = Color.fromRGBO(53, 57, 70, 0.3);

class TherapistNotesScreen extends ConsumerStatefulWidget {
  final String patientName;
  final String appointmentId;
  const TherapistNotesScreen({super.key, required this.patientName, required this.appointmentId});

  @override
  ConsumerState<TherapistNotesScreen> createState() => _TherapistNotesScreenState();
}

class _TherapistNotesScreenState extends ConsumerState<TherapistNotesScreen> {
  final _summaryController = TextEditingController();
  final _goalsController = TextEditingController();
  final _homeworkController = TextEditingController();
  
  bool _shareWithNova = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _summaryController.dispose();
    _goalsController.dispose();
    _homeworkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundDeep,
      body: Stack(
        children: [
          // Ambient Glows
          Positioned(top: -100, right: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(color: _primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120), child: const SizedBox()))),
          
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
                        Text('Session Wrap-Up', style: GoogleFonts.manrope(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text('Document notes for ${widget.patientName}', style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFFC9C4D0))),
                        const SizedBox(height: 32),
                        
                        _buildInputField('Clinical Summary (Private)', _summaryController, maxLines: 4),
                        const SizedBox(height: 24),
                        
                        _buildInputField('Session Goals & Progress', _goalsController, maxLines: 3),
                        const SizedBox(height: 24),
                        
                        _buildInputField('Recommended Follow-Up Tasks (Homework)', _homeworkController, maxLines: 3),
                        const SizedBox(height: 32),
                        
                        _buildNovaIntegrationToggle(),
                        const SizedBox(height: 48),
                        
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : () async {
                              if (_summaryController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a clinical summary.')));
                                return;
                              }
                              
                              setState(() => _isSubmitting = true);
                              try {
                                final dio = ref.read(apiClientProvider).dio;
                                final rawNotes = [
                                  'Summary: ${_summaryController.text}',
                                  if (_goalsController.text.isNotEmpty) 'Goals: ${_goalsController.text}',
                                  if (_homeworkController.text.isNotEmpty) 'Homework: ${_homeworkController.text}'
                                ].join('\n\n');
                                
                                // Assuming we pass the patient's ID or session ID as extra in real life.
                                // For now we'll post to the patient directly as a dummy appointmentId.
                                await dio.post('/therapists/ai/post-session/${widget.appointmentId}', data: {
                                  'rawNotes': rawNotes,
                                });

                                // Mark session as complete so it moves to history
                                await dio.post('/therapist-panel/complete', data: {
                                  'appointmentId': widget.appointmentId,
                                });

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notes Saved Successfully.')));
                                  context.pop();
                                }
                              } catch (e) {
                                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
                              } finally {
                                if (mounted) setState(() => _isSubmitting = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              disabledBackgroundColor: const Color(0xFF353946),
                              foregroundColor: const Color(0xFF32285E),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _isSubmitting 
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF32285E)))
                                : Text('Submit Notes', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                          ),
                        ),
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
          Expanded(child: Text('Therapist Notes', textAlign: TextAlign.center, style: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: _primaryColor))),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _glassBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _glassBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _primaryColor)),
          ),
        ),
      ],
    );
  }

  Widget _buildNovaIntegrationToggle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2C).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _glassBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _secondaryColor.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: _secondaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sync with Nova AI', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('Allow Nova to track these goals and send reminders to the patient.', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFC9C4D0))),
              ],
            ),
          ),
          Switch(
            value: _shareWithNova,
            onChanged: (val) => setState(() => _shareWithNova = val),
            activeColor: _secondaryColor,
            activeTrackColor: _secondaryColor.withValues(alpha: 0.3),
            inactiveThumbColor: const Color(0xFFC9C4D0),
            inactiveTrackColor: const Color(0xFF353946),
          ),
        ],
      ),
    );
  }
}
